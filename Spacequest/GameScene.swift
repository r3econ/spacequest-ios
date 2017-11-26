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

protocol GameSceneDelegate: class {
    func didTapMainMenuButton(in gameScene: GameScene)
    func playerDidLose(withScore score: Int, in gameScene:GameScene)
}

class GameScene: SKScene {
    
    private struct Constants {
        static let hudControlMargin: CGFloat = 20.0
        static let maxRandomTimeBetweenEnemySpawns: UInt32 = 3
        static let scoresNodeBottomMargin: CGFloat = 26.0
        static let fireButtonBottomMargin: CGFloat = 40.0
        static let joystickMaximumRadius: CGFloat = 40.0
        static let initialEnemyLifePoints = 20
        static let enemyFlightDuration: TimeInterval = 4.0
        static let explosionEmmiterFileName = "Explosion"
    }
    
    weak var gameSceneDelegate: GameSceneDelegate?
    
    // Nodes
    private var background: SKSpriteNode?
    private var playerSpaceship: PlayerSpaceship?
    private var joystick: Joystick?
    private var fireButton: Button?
    private var menuButton: Button?
    private let lifeIndicator = LifeIndicator(texture: SKTexture(imageNamed: ImageName.LifeBall.rawValue))
    private let scoresNode = ScoresNode()
    
    /// Timer used for spawning enemy spaceships
    private var spawnEnemyTimer: Timer?
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Set scale mode
        self.scaleMode = SKSceneScaleMode.resizeFill;

        // Configure scene contents
        self.configureBackground()
        self.configurePlayerSpaceship()
        self.configurePhysics()
        self.configureHUD()
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
            if self.isPaused != oldValue {
                if self.isPaused {
                    self.stopSpawningEnemySpaceships()
                }
                else {
                    self.startSpawningEnemySpaceships()
                }
            }
        }
    }
    
}

// MARK: - Managing enemies

extension GameScene {
    
    private func startSpawningEnemySpaceships() {
        self.scheduleEnemySpaceshipSpawn()
    }
    
    private func stopSpawningEnemySpaceships() {
        self.spawnEnemyTimer?.invalidate()
    }
    
    private func scheduleEnemySpaceshipSpawn() {
        let randomTimeInterval = TimeInterval(arc4random_uniform(Constants.maxRandomTimeBetweenEnemySpawns) + 1)
        self.spawnEnemyTimer = Timer.scheduledTimer(
            timeInterval: randomTimeInterval,
            target: self,
            selector: #selector(GameScene.spawnEnemyTimerFireMethod),
            userInfo: nil,
            repeats: false)
    }
    
    @objc private func spawnEnemyTimerFireMethod() {
        // Spawn enemy spaceship
        self.spawnEnemySpaceship()
        // Schedule spawn of the next one
        self.scheduleEnemySpaceshipSpawn()
    }
    
    private func spawnEnemySpaceship() {
        let enemySpaceship = EnemySpaceship(lifePoints: Constants.initialEnemyLifePoints)
        enemySpaceship.didRunOutOfLifePointsEventHandler = enemyDidRunOutOfLifePointsEventHandler()
        
        // Determine where to spawn the enemy along the Y axis
        let minY = enemySpaceship.size.height
        let maxY = self.frame.height - enemySpaceship.size.height
        let rangeY = maxY - minY
        let randomY: UInt32 = arc4random_uniform(UInt32(rangeY)) + UInt32(minY)
        
        // Set position of the enemy to be slightly off-screen along the right edge,
        // and along a random position along the Y axis
        enemySpaceship.position = CGPoint(x: frame.size.width + enemySpaceship.size.width/2, y: CGFloat(randomY))
        enemySpaceship.zPosition = self.playerSpaceship!.zPosition
        
        // Add it to the scene
        self.addChild(enemySpaceship)
        
        // Determine speed of the enemy
        let moveAction = SKAction.moveTo(x: -enemySpaceship.size.width/2, duration: Constants.enemyFlightDuration)
        enemySpaceship.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
}

// MARK: - Configuration

extension GameScene {
    
    private func configurePhysics() {
        // Disable gravity
        self.physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        self.physicsWorld.contactDelegate = self
        
        // Add boundaries
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody!.categoryBitMask = CategoryBitmask.screenBounds.rawValue
        self.physicsBody!.collisionBitMask = CategoryBitmask.playerSpaceship.rawValue
    }
    
    private func configurePlayerSpaceship() {
        self.playerSpaceship = PlayerSpaceship()
        // Position
        self.playerSpaceship!.position = CGPoint(x: self.playerSpaceship!.size.width/2 + 30.0,
                                                 y: self.frame.height/2 + 40.0)
        // Life points
        self.playerSpaceship!.lifePoints = 100
        self.playerSpaceship!.didRunOutOfLifePointsEventHandler = self.playerDidRunOutOfLifePointsEventHandler()
        // Add it to the scene
        self.addChild(self.playerSpaceship!)
    }
    
    private func configureJoystick() {
        self.joystick = Joystick(maximumRadius: Constants.joystickMaximumRadius,
                                 stickImageNamed: ImageName.JoystickStick.rawValue,
                                 baseImageNamed: ImageName.JoystickBase.rawValue)
        // Position
        self.joystick!.position = CGPoint(x: self.joystick!.size.width,
                                          y: self.joystick!.size.height)
        // Handler that gets called on joystick move
        self.joystick!.updateHandler = { (translation: CGPoint) -> () in
            self.updatePlayerSpaceshipPositionWithJoystickTranslation(translation)
        }
        // Add it to the scene
        self.addChild(self.joystick!)
    }
    
    private func configureFireButton() {
        self.fireButton = Button(normalImageNamed: ImageName.FireButtonNormal.rawValue,
                                 selectedImageNamed: ImageName.FireButtonSelected.rawValue)
        self.fireButton!.position = CGPoint(x: self.frame.width - fireButton!.frame.width - Constants.hudControlMargin,
                                            y: self.fireButton!.frame.height/2 + Constants.fireButtonBottomMargin)
        // Touch handler
        self.fireButton!.touchUpInsideEventHandler = { () -> () in
            self.playerSpaceship!.launchMissile()
            return
        }
        // Add it to the scene
        self.addChild(self.fireButton!)
    }
    
    private func configureMenuButton() {
        self.menuButton = Button(normalImageNamed: ImageName.ShowMenuButtonNormal.rawValue,
                                 selectedImageNamed: ImageName.ShowMenuButtonSelected.rawValue)
        self.menuButton!.position = CGPoint(x: self.frame.width - self.menuButton!.frame.width/2 - 2.0,
                                            y: self.frame.height - self.menuButton!.frame.height/2)
        // Touch handler
        self.menuButton!.touchUpInsideEventHandler = { () -> () in
            self.gameSceneDelegate?.didTapMainMenuButton(in: self)
            return
        }
        // Add it to the scene
        self.addChild(self.menuButton!)
    }
    
    private func configureLifeIndicator() {
        // Position
        self.lifeIndicator.position = CGPoint(x: self.joystick!.frame.maxX + 2.5 * self.joystick!.joystickRadius,
                                              y: self.joystick!.frame.minY - self.joystick!.joystickRadius)
        // Life points
        self.lifeIndicator.setLifePoints(self.playerSpaceship!.lifePoints, animated: false)
        // Add it to the scene
        self.addChild(self.lifeIndicator)
    }
    
    private func configureScoresNode() {
        // Position
        self.scoresNode.position = CGPoint(x: Constants.hudControlMargin/2, y: self.frame.height - Constants.scoresNodeBottomMargin)
        // Add it to the scene
        self.addChild(self.scoresNode)
    }
    
    private func configureBackground() {
        // Create background node
        let background = SKSpriteNode(imageNamed: ImageName.GameBackgroundPhone.rawValue)
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = -1000
        
        // Node with trees
        let trees = SKSpriteNode(imageNamed: ImageName.BackgroundTrees.rawValue)
        trees.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        trees.position = CGPoint(x: -self.size.width/2, y: -self.size.height/2)
        background.addChild(trees)
        
        // Add background to the scene
        self.addChild(background)
        self.background = background
    }
    
    private func updatePlayerSpaceshipPositionWithJoystickTranslation(_ translation: CGPoint) {
        let translationConstant: CGFloat = 10.0
        self.playerSpaceship!.position.x += translationConstant * translation.x
        self.playerSpaceship!.position.y += translationConstant * translation.y
    }
    
    private func configureHUD() {
        self.configureJoystick()
        self.configureFireButton()
        self.configureLifeIndicator()
        self.configureMenuButton()
        self.configureScoresNode()
    }
    
}


// MARK: - Collision detection

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Get collision type
        let collisionType: CollisionType? = self.collisionTypeWithContact(contact)
        guard collisionType != nil else {
            return
        }
        
        switch collisionType! {
        case .playerMissileEnemySpaceship:
            // Get the enemy node
            var enemy: EnemySpaceship
            var missile: Missile
            
            if contact.bodyA.node as? EnemySpaceship != nil {
                enemy = contact.bodyA.node as! EnemySpaceship
                missile = contact.bodyB.node as! Missile
            } else {
                enemy = contact.bodyB.node as! EnemySpaceship
                missile = contact.bodyA.node as! Missile
            }
            
            // Handle collision
            self.handleCollision(between: missile, and: enemy)
            
        case .playerSpaceshipEnemySpaceship:
            // Get the enemy node
            let enemy: EnemySpaceship = contact.bodyA.node as? EnemySpaceship != nil ?
                contact.bodyA.node as! EnemySpaceship :
                contact.bodyB.node as! EnemySpaceship
            
            // Handle collision
            self.handleCollision(between: playerSpaceship!, and: enemy)
            
        case .enemyMissilePlayerSpaceship:
            // Get the enemy node
            let missile: Missile = contact.bodyA.node as? Missile != nil ?
                contact.bodyA.node as! Missile :
                contact.bodyB.node as! Missile
            
            // Handle collision
            self.handleCollision(between: playerSpaceship!, and: missile)
        }
    }
    
    private func collisionTypeWithContact(_ contact: SKPhysicsContact!) -> (CollisionType?) {
        guard
            let categoryBitmaskBodyA = CategoryBitmask(rawValue: contact.bodyA.categoryBitMask),
            let categoryBitmaskBodyB = CategoryBitmask(rawValue: contact.bodyB.categoryBitMask) else {
                return nil
        }
        
        switch (categoryBitmaskBodyA, categoryBitmaskBodyB) {
            // Player missile - enemy spaceship
        case (.enemySpaceship, .playerMissile), (.playerMissile, .enemySpaceship):
            return .playerMissileEnemySpaceship
            
            // Player spaceship - enemy spaceship
        case (.enemySpaceship, .playerSpaceship), (.playerSpaceship, .enemySpaceship):
            return .playerSpaceshipEnemySpaceship
            
        default:
            return nil
        }
    }
    
}

// MARK: - Collision handling

extension GameScene {
    
    /// Handle collision between player spaceship and the enemy spaceship
    private func handleCollision(between playerSpaceship: PlayerSpaceship, and enemySpaceship: EnemySpaceship!) {
        // Update score
        self.increaseScore(by: ScoreValue.playerMissileHitEnemySpaceship.rawValue)
        // Update life points
        self.decreasePlayerSpaceshipLifePoints(by: LifePointsValue.enemySpaceshipHitPlayerSpaceship.rawValue)
        self.decreaseLifePoints(of: enemySpaceship, by: LifePointsValue.enemySpaceshipHitPlayerSpaceship.rawValue)
    }
    
    private func handleCollision(between playerMissile: Missile, and enemySpaceship: EnemySpaceship) {
        // Remove missile
        playerMissile.removeFromParent()
        // Update score
        self.increaseScore(by: ScoreValue.playerMissileHitEnemySpaceship.rawValue)
        // Update life points
        self.decreaseLifePoints(of: enemySpaceship, by: LifePointsValue.playerMissileHitEnemySpaceship.rawValue)
    }
    
    private func handleCollision(between playerSpaceship: PlayerSpaceship, and enemyMissile: Missile) {
        // Not supported
    }
    
}

// MARK: - Scores

extension GameScene {
    
    private func increaseScore(by value: Int) {
        self.scoresNode.value += value
    }
    
}

// MARK: - Life points

extension GameScene {
    
    private func increasePlayerSpaceshipLifePoints(by value: Int) {
        self.playerSpaceship!.lifePoints += value
        self.lifeIndicator.setLifePoints(self.playerSpaceship!.lifePoints, animated: true)
        
        // Add a green color blend for a short moment to indicate the increase of health
        let colorizeAction = SKAction.colorize(with: UIColor.green,
                                               colorBlendFactor: 0.7,
                                               duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        
        self.playerSpaceship!.run(SKAction.sequence([colorizeAction, uncolorizeAction]))
    }
    
    private func decreasePlayerSpaceshipLifePoints(by value: Int) {
        self.playerSpaceship!.lifePoints += value
        self.lifeIndicator.setLifePoints(self.playerSpaceship!.lifePoints, animated: true)
        
        // Add a red color blend for a short moment to indicate the decrease of health
        let colorizeAction = SKAction.colorize(with: UIColor.red,
                                               colorBlendFactor: 0.7,
                                               duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0,
                                                 duration: 0.2)
        self.playerSpaceship!.run(SKAction.sequence([colorizeAction, uncolorizeAction]))
    }
    
    private func decreaseLifePoints(of enemySpaceship: EnemySpaceship, by value: Int) {
        enemySpaceship.lifePoints += value
        
        // Add a red color blend for a short moment to indicate the decrease of health
        let colorizeAction = SKAction.colorize(with: UIColor.red,
                                               colorBlendFactor: 0.7,
                                               duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0,
                                                 duration: 0.2)
        enemySpaceship.run(SKAction.sequence([colorizeAction, uncolorizeAction]))
    }
    
    private func enemyDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        return { (object: AnyObject) -> () in
            let enemySpaceship = object as! EnemySpaceship
            self.destroySpaceship(enemySpaceship)
        }
    }
    
    private func playerDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        return { (object: AnyObject) -> () in
            self.destroySpaceship(self.playerSpaceship)
            self.gameSceneDelegate?.playerDidLose(withScore: self.scoresNode.value, in: self)
        }
    }
    
    private func destroySpaceship(_ spaceship: Spaceship!) {
        // Create an explosion
        let explosionEmitter = SKEmitterNode(fileNamed: Constants.explosionEmmiterFileName)
        // Position it
        explosionEmitter!.position.x = spaceship.position.x - spaceship.size.width/2
        explosionEmitter!.position.y = spaceship.position.y
        explosionEmitter!.zPosition = spaceship.zPosition + 1
        // Add it to the scene
        self.addChild(explosionEmitter!)
        explosionEmitter!.run(SKAction.sequence([SKAction.wait(forDuration: 5), SKAction.removeFromParent()]))
        // Fade out the enemy and remove it
        spaceship.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.removeFromParent()]))
        // Play explosion sound
        self.scene!.run(SKAction.playSoundFileNamed(SoundName.Explosion.rawValue, waitForCompletion: false))
    }
    
}

