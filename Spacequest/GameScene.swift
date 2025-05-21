//
// Copyright (c) 2016 Rafał Sroka
//
// Licensed under the GNU General Public License, Version 3.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
//   https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func didTapMainMenuButton(in gameScene: GameScene)
    func playerDidLose(withScore score: Int, in gameScene:GameScene)
}

class GameScene: SKScene {

    private struct Constants {
        static let maxRandomTimeBetweenEnemySpawns: UInt32 = 1300
        static let scoresNodeLeftMargin: CGFloat = 60.0
        static let scoresNodeTopMargin: CGFloat = 40.0
        static let fireButtonRightMargin: CGFloat = 60.0
        static let fireButtonBottomMargin: CGFloat = 40.0
        static let joystickMaximumRadius: CGFloat = 40.0
        static let joystickLeftMargin: CGFloat = 40.0
        static let menuButtonMargin: CGFloat = 20.0
        static let initialEnemyLifePoints = 20
        static let enemyFlightDuration: TimeInterval = 2.0
        static let explosionEmitterFileName = "Explosion"
    }

    weak var gameSceneDelegate: GameSceneDelegate?

    // Nodes
    private var background: SKSpriteNode?
    private var playerSpaceship = PlayerSpaceship()
    private var joystick: Joystick?
    private var fireButton: Button?
    private var menuButton: Button?
    private let lifeIndicator = LifeIndicator(texture: SKTexture(imageNamed: ImageName.LifeBall.rawValue))
    private let scoresNode = ScoresNode()

    /// Timer used for spawning enemy spaceships
    private var spawnEnemyTimer: Timer?

    // MARK: - Scene lifecycle

    override func sceneDidLoad() {
        super.sceneDidLoad()

        // Set scale mode
        scaleMode = SKSceneScaleMode.resizeFill;

        // Configure scene contents
        configureBackground()
        configurePlayerSpaceship()
        configurePhysics()
        configureHUD()

        // Start the fun
        startSpawningEnemySpaceships()
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Enable multitouch
        view.isMultipleTouchEnabled = true
        // Track showing the scene
        AnalyticsManager.sharedInstance.trackScene("GameScene")
    }

    override var isPaused: Bool {
        didSet {
            // Control enemy spawning
            if isPaused != oldValue {
                if isPaused {
                    stopSpawningEnemySpaceships()
                }
                else {
                    startSpawningEnemySpaceships()
                }
            }
        }
    }

}

// MARK: - Managing enemies

extension GameScene {

    private func startSpawningEnemySpaceships() {
        scheduleEnemySpaceshipSpawn()
    }

    private func stopSpawningEnemySpaceships() {
        spawnEnemyTimer?.invalidate()
    }

    private func scheduleEnemySpaceshipSpawn() {
        let randomTimeInterval = TimeInterval(Double(UInt32.random(in: 1...Constants.maxRandomTimeBetweenEnemySpawns))/1000.0)
        spawnEnemyTimer = Timer.scheduledTimer(
            timeInterval: randomTimeInterval,
            target: self,
            selector: #selector(GameScene.spawnEnemyTimerFireMethod),
            userInfo: nil,
            repeats: false)
    }

    @objc private func spawnEnemyTimerFireMethod() {
        // Spawn enemy spaceship
        spawnEnemySpaceship()
        // Schedule spawn of the next one
        scheduleEnemySpaceshipSpawn()
    }

    private func spawnEnemySpaceship() {
        let enemySpaceship = EnemySpaceship(lifePoints: Constants.initialEnemyLifePoints)
        enemySpaceship.didRunOutOfLifePointsEventHandler = enemyDidRunOutOfLifePointsEventHandler()

        // Determine where to spawn the enemy along the Y axis
        let minY = enemySpaceship.size.height
        let maxY = frame.height - enemySpaceship.size.height
        let rangeY = maxY - minY
        let randomY = UInt32.random(in: UInt32(minY)..<(UInt32(minY) + UInt32(rangeY)))

        // Set position of the enemy to be slightly off-screen along the right edge,
        // and along a random position along the Y axis
        enemySpaceship.position = CGPoint(x: frame.size.width + enemySpaceship.size.width/2,
                                          y: CGFloat(randomY))
        enemySpaceship.zPosition = playerSpaceship.zPosition

        // Add it to the scene
        addChild(enemySpaceship)

        // Determine speed of the enemy
        let moveAction = SKAction.moveTo(x: -enemySpaceship.size.width/2,
                                         duration: Constants.enemyFlightDuration)
        enemySpaceship.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }

}

// MARK: - Configuration

extension GameScene {

    private func configurePhysics() {
        // Disable gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        // Add boundaries
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = CategoryBitmask.screenBounds.rawValue
        physicsBody!.collisionBitMask = CategoryBitmask.playerSpaceship.rawValue
    }

    private func configurePlayerSpaceship() {
        // Start position
        playerSpaceship.position = CGPoint(x: playerSpaceship.size.width/2 + 160.0,
                                           y: frame.height/2 + 40.0)
        // Life points
        playerSpaceship.lifePoints = 100
        playerSpaceship.didRunOutOfLifePointsEventHandler = playerDidRunOutOfLifePointsEventHandler()

        addChild(playerSpaceship)
    }

    private func configureJoystick() {
        let newJoystick = Joystick(maximumRadius: Constants.joystickMaximumRadius,
                                   stickImageNamed: ImageName.JoystickStick.rawValue,
                                   baseImageNamed: ImageName.JoystickBase.rawValue)
        // Position
        newJoystick.position = CGPoint(x: newJoystick.size.width + Constants.joystickLeftMargin,
                                       y: newJoystick.size.height)
        // Handler that gets called on joystick move
        newJoystick.updateHandler = { [weak self] joystickTranslation in
            self?.updatePlayerSpaceshipPosition(with: joystickTranslation)
        }
        self.joystick = newJoystick
        addChild(newJoystick)
    }

    private func configureFireButton() {
        let newFireButton = Button(normalImageNamed: ImageName.FireButtonNormal.rawValue,
                                   selectedImageNamed: ImageName.FireButtonSelected.rawValue)
        newFireButton.position = CGPoint(x: frame.width - newFireButton.frame.width - Constants.fireButtonRightMargin,
                                         y: newFireButton.frame.height/2 + Constants.fireButtonBottomMargin)
        // Touch handler
        newFireButton.touchUpInsideEventHandler = { [weak self] in
            self?.playerSpaceship.launchMissile()
        }
        self.fireButton = newFireButton
        addChild(newFireButton)
    }

    private func configureMenuButton() {
        let newMenuButton = Button(normalImageNamed: ImageName.ShowMenuButtonNormal.rawValue,
                                   selectedImageNamed: ImageName.ShowMenuButtonSelected.rawValue)
        newMenuButton.position = CGPoint(x: frame.width - newMenuButton.frame.width/2 - Constants.menuButtonMargin,
                                         y: frame.height - newMenuButton.frame.height/2 - Constants.menuButtonMargin)
        // Touch handler
        newMenuButton.touchUpInsideEventHandler = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.gameSceneDelegate?.didTapMainMenuButton(in: strongSelf)
        }
        self.menuButton = newMenuButton
        addChild(newMenuButton)
    }

    private func configureLifeIndicator() {
        guard let joystick = self.joystick else {
            print("Error: Joystick not initialized before configuring LifeIndicator.")
            return
        }
        // Position
        lifeIndicator.position = CGPoint(x: joystick.frame.maxX + 2.5 * joystick.joystickRadius,
                                         y: joystick.frame.minY - joystick.joystickRadius)
        // Life points
        lifeIndicator.setLifePoints(playerSpaceship.lifePoints, animated: false)
        addChild(lifeIndicator)
    }

    private func configureScoresNode() {
        scoresNode.position = CGPoint(x: Constants.scoresNodeLeftMargin,
                                      y: frame.height - Constants.scoresNodeTopMargin)
        addChild(scoresNode)
    }

    private func configureBackground() {
        // Create background node
        let backgroundNode = SKSpriteNode(imageNamed: ImageName.GameBackgroundPhone.rawValue)
        backgroundNode.size = size
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundNode.zPosition = -1000

        // Node with trees
        let trees = SKSpriteNode(imageNamed: ImageName.BackgroundTrees.rawValue)
        trees.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        trees.position = CGPoint(x: -size.width/2, y: -size.height/2)
        trees.zPosition = 2
        backgroundNode.addChild(trees)

        addChild(backgroundNode)
        background = backgroundNode
    }

    private func updatePlayerSpaceshipPosition(with joystickTranslation: CGPoint) {
        let translationConstant: CGFloat = 10.0
        playerSpaceship.position.x += translationConstant * joystickTranslation.x
        playerSpaceship.position.y += translationConstant * joystickTranslation.y
    }

    private func configureHUD() {
        configureJoystick()
        configureFireButton()
        configureLifeIndicator()
        configureMenuButton()
        configureScoresNode()
    }

}


// MARK: - Collision detection

extension GameScene : SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        // Get collision type
        guard let collisionType = self.collisionType(for: contact) else { return }

        switch collisionType {
        case .playerMissileEnemySpaceship:
            guard let (missile, enemy) = getNodes(from: contact, typeA: Missile.self, typeB: EnemySpaceship.self) else { return }
            handleCollision(between: missile, and: enemy)

        case .playerSpaceshipEnemySpaceship:
            guard let (nodeA, nodeB) = getNodes(from: contact, typeA: PlayerSpaceship.self, typeB: EnemySpaceship.self) else { return }
            let playerSpaceship = nodeA // Assuming playerSpaceship is always typeA if this case matches.
            let enemy = nodeB
            handleCollision(between: playerSpaceship, and: enemy)

        case .enemyMissilePlayerSpaceship:
            guard let (missile, player) = getNodes(from: contact, typeA: Missile.self, typeB: PlayerSpaceship.self) else { return }
            handleCollision(between: player, and: missile)
        }
    }

    private func getNodes<T: SKNode, U: SKNode>(from contact: SKPhysicsContact, typeA: T.Type, typeB: U.Type) -> (T, U)? {
        if let nodeA = contact.bodyA.node as? T, let nodeB = contact.bodyB.node as? U {
            return (nodeA, nodeB)
        } else if let nodeA = contact.bodyB.node as? T, let nodeB = contact.bodyA.node as? U {
            return (nodeA, nodeB)
        }
        return nil
    }
    
    func collisionType(for contact: SKPhysicsContact!) -> CollisionType? { // Made internal
        guard
            let categoryBitmaskBodyA = CategoryBitmask(rawValue: contact.bodyA.categoryBitMask),
            let categoryBitmaskBodyB = CategoryBitmask(rawValue: contact.bodyB.categoryBitMask) else {
            return nil
        }

        switch (categoryBitmaskBodyA, categoryBitmaskBodyB) {
            // Player missile - enemy spaceship
        case (.enemySpaceship, .playerMissile),
            (.playerMissile, .enemySpaceship):
            return .playerMissileEnemySpaceship

            // Player spaceship - enemy spaceship
        case (.enemySpaceship, .playerSpaceship),
            (.playerSpaceship, .enemySpaceship):
            return .playerSpaceshipEnemySpaceship

        default:
            return nil
        }
    }

}

// MARK: - Collision handling

extension GameScene {

    /// Handle collision between player spaceship and the enemy spaceship
    private func handleCollision(between playerSpaceship: PlayerSpaceship,
                                 and enemySpaceship: EnemySpaceship!) {
        // Update score
        increaseScore(by: ScoreValue.playerMissileHitEnemySpaceship.rawValue)
        // Update life points
        modifyPlayerSpaceshipLifePoints(by: LifePointsValue.enemySpaceshipHitPlayerSpaceship.rawValue)
        modifyLifePoints(of: enemySpaceship,
                         by: LifePointsValue.enemySpaceshipHitPlayerSpaceship.rawValue)
    }

    private func handleCollision(between playerMissile: Missile,
                                 and enemySpaceship: EnemySpaceship) {
        // Remove missile
        playerMissile.removeFromParent()
        // Update score
        increaseScore(by: ScoreValue.playerMissileHitEnemySpaceship.rawValue)
        // Update life points
        modifyLifePoints(of: enemySpaceship,
                         by: LifePointsValue.playerMissileHitEnemySpaceship.rawValue)
    }

    private func handleCollision(between playerSpaceship: PlayerSpaceship,
                                 and enemyMissile: Missile) {
        // Not supported
    }

}

// MARK: - Scores

extension GameScene {

    private func increaseScore(by value: Int) {
        scoresNode.value += value
    }

}

// MARK: - Life points

extension GameScene {

    private func modifyPlayerSpaceshipLifePoints(by value: Int) {
        playerSpaceship.lifePoints += value
        lifeIndicator.setLifePoints(playerSpaceship.lifePoints, animated: true)

        // Add a color blend for a short moment to indicate the change of health
        let color: UIColor = value > 0 ? .green : .red
        playerSpaceship.run(blendColorAction(with: color))
    }

    private func modifyLifePoints(of enemySpaceship: EnemySpaceship, by value: Int) {
        enemySpaceship.lifePoints += value

        // Add a color blend for a short moment to indicate the change of health
        let color: UIColor = value > 0 ? .green : .red
        enemySpaceship.run(blendColorAction(with: color))
    }

    private func blendColorAction(with color: UIColor) -> SKAction {
        let colorizeAction = SKAction.colorize(with: .red,
                                               colorBlendFactor: 0.7,
                                               duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0,
                                                 duration: 0.2)
        return SKAction.sequence([colorizeAction, uncolorizeAction])
    }

    private func enemyDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        return { [weak self] spaceship in
            // The spaceship parameter is already of type Spaceship.
            // destroySpaceship expects a Spaceship, so no further cast is needed here
            // unless specific EnemySpaceship properties were to be accessed.
            self?.destroySpaceship(spaceship)
        }
    }

    private func playerDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        return { [weak self] spaceship in
            guard let strongSelf = self else { return }

            // The `spaceship` parameter should be the playerSpaceship that ran out of life points.
            strongSelf.destroySpaceship(spaceship)
            strongSelf.gameSceneDelegate?.playerDidLose(withScore: strongSelf.scoresNode.value,
                                                        in: strongSelf)
        }
    }

    private func destroySpaceship(_ spaceship: Spaceship!) {
        // Create an explosion
        if let explosionEmitter = SKEmitterNode(fileNamed: Constants.explosionEmitterFileName) {
            // Position it
            explosionEmitter.position.x = spaceship.position.x - spaceship.size.width/2
            explosionEmitter.position.y = spaceship.position.y
            explosionEmitter.zPosition = spaceship.zPosition + 1
            // Add it to the scene
            addChild(explosionEmitter)
            explosionEmitter.run(SKAction.sequence([SKAction.wait(forDuration: 5),
                                                     SKAction.removeFromParent()]))
        } else {
            print("Warning: Could not load explosion particle effect: \(Constants.explosionEmitterFileName)")
        }
        // Fade out the enemy and remove it
        spaceship.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1),
                                         SKAction.removeFromParent()]))
        // Play explosion sound
        run(SKAction.playSoundFileNamed(SoundName.Explosion.rawValue,
                                               waitForCompletion: false))
    }

}
