import SpriteKit

protocol GameSceneDelegate: class {
    func gameSceneDidTapMainMenuButton(_ gameScene: GameScene)
    func gameScene(_ gameScene:GameScene, playerDidLoseWithScore: Int)
}

let kHUDControlMargin: CGFloat = 20.0

class GameScene: SKScene{

    fileprivate var background: BackgroundNode?
    fileprivate var playerSpaceship: PlayerSpaceship?
    fileprivate var joystick: Joystick?
    fileprivate var fireButton: Button?
    fileprivate var menuButton: Button?
    fileprivate let lifeIndicator = LifeIndicator(texture: SKTexture(imageNamed: ImageName.LifeBall.rawValue))
    fileprivate let scoresNode = ScoresNode()
    fileprivate var launchEnemyTimer: Timer?
    weak var gameSceneDelegate: GameSceneDelegate?

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)

        self.configureBackground()
        self.configurePlayerSpaceship()
        self.configurePhysics()
        self.configureHUD()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Enable multitouch
        view.isMultipleTouchEnabled = true
        
        // Track event
        AnalyticsManager.sharedInstance.trackScene("GameScene")
    }
   
    override func update(_ currentTime: TimeInterval) {
        // Update the background.
        if self.isPaused == false {
            self.background!.update(currentTime)
        }
    }
    
    override var isPaused: Bool {
        didSet {
            // Control launching of the enemies.
            if self.isPaused != oldValue {
                if self.isPaused {
                    self.stopLaunchingEnemySpaceships()
                }
                else {
                    self.startLaunchingEnemySpaceships()
                }
            }
        }
    }
    
}

// MARK: - Managing enemies

extension GameScene {
    
    fileprivate func startLaunchingEnemySpaceships() {
        self.scheduleEnemySpaceshipLaunch()
    }
    
    fileprivate func stopLaunchingEnemySpaceships() {
        
        if self.launchEnemyTimer != nil {
            self.launchEnemyTimer!.invalidate()
        }
    }
    
    fileprivate func scheduleEnemySpaceshipLaunch() {
        let randomTimeInterval = TimeInterval(arc4random_uniform(3) + 1)

        self.launchEnemyTimer = Timer.scheduledTimer(
            timeInterval: randomTimeInterval,
            target: self,
            selector: #selector(GameScene.launchEnemyTimerFireMethod),
            userInfo: nil,
            repeats: false)
    }
    
    @objc fileprivate func launchEnemyTimerFireMethod() {
        // Launch an enemy.
        self.launchEnemySpaceship()
        
        // Schedule launch of the next one.
        self.scheduleEnemySpaceshipLaunch()
    }
    
    fileprivate func launchEnemySpaceship() {
        let enemySpaceship = EnemySpaceship(lifePoints: 20)
        
        enemySpaceship.didRunOutOfLifePointsEventHandler = enemyDidRunOutOfLifePointsEventHandler()
        
        // Determine where to spawn the enemy along the Y axis.
        let minY = enemySpaceship.size.height;
        let maxY = self.frame.height - enemySpaceship.size.height
        let rangeY = maxY - minY
        let randomY: UInt32 = arc4random_uniform(UInt32(rangeY)) + UInt32(minY)
        
        // Set position of the enemy to be slightly off-screen along the right edge,
        // and along a random position along the Y axis.
        enemySpaceship.position = CGPoint(x: frame.size.width + enemySpaceship.size.width/2, y: CGFloat(randomY))
        enemySpaceship.zPosition = self.playerSpaceship!.zPosition
            
        self.addChild(enemySpaceship)
        
        // Determine speed of the enemy.
        let enemyFlightDuration = 4.0
        let moveAction = SKAction.moveTo(x: -enemySpaceship.size.width/2, duration: enemyFlightDuration)
        
        enemySpaceship.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
}

// MARK: - Configuration

extension GameScene {
    
    fileprivate func configurePhysics() {
        self.physicsWorld.gravity = CGVector(dx: 0,dy: 0);
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody!.categoryBitMask = CategoryBitmask.screenBounds.rawValue
        self.physicsBody!.collisionBitMask = CategoryBitmask.playerSpaceship.rawValue
    }
    
    fileprivate func configurePlayerSpaceship() {
        self.playerSpaceship = PlayerSpaceship()
        
        self.playerSpaceship!.position = CGPoint(
            x: self.playerSpaceship!.size.width/2 + 30.0,
            y: self.frame.height/2 + 40.0);
        
        self.playerSpaceship!.lifePoints = 100
        self.playerSpaceship!.didRunOutOfLifePointsEventHandler = self.playerDidRunOutOfLifePointsEventHandler()
        
        self.addChild(self.playerSpaceship!)
    }
    
    fileprivate func configureJoystick() {
        self.joystick = Joystick(
            maximumRadius: 40.0,
            stickImageNamed: ImageName.JoystickStick.rawValue,
            baseImageNamed: ImageName.JoystickBase.rawValue);
        
        self.joystick!.position = CGPoint(
            x: self.joystick!.size.width,
            y: self.joystick!.size.height);
        
        
        self.joystick!.updateHandler = { (translation: CGPoint) -> () in
                self.updatePlayerSpaceshipPositionWithJoystickTranslation(translation);
        }
        
        self.addChild(self.joystick!)
    }
    
    fileprivate func configureFireButton() {
        self.fireButton = Button(
            normalImageNamed: ImageName.FireButtonNormal.rawValue,
            selectedImageNamed: ImageName.FireButtonSelected.rawValue)
        
        self.fireButton!.position = CGPoint(
            x: self.frame.width - fireButton!.frame.width - kHUDControlMargin,
            y: fireButton!.frame.height/2 + 40.0);
        
        self.fireButton!.touchUpInsideEventHandler = {
            
            () -> () in
                        
            self.playerSpaceship!.launchMissile()
            return
        }
        
        self.addChild(self.fireButton!)
    }
    
    fileprivate func configureMenuButton() {
        self.menuButton = Button(
            normalImageNamed: ImageName.ShowMenuButtonNormal.rawValue,
            selectedImageNamed: ImageName.ShowMenuButtonSelected.rawValue)
        
        self.menuButton!.position = CGPoint(
            x: self.frame.width - self.menuButton!.frame.width/2 - 2.0,
            y: self.frame.height - self.menuButton!.frame.height/2);
        
        self.menuButton!.touchUpInsideEventHandler = {
            
                () -> () in
                
                self.gameSceneDelegate?.gameSceneDidTapMainMenuButton(self)
                return
        }
        
        self.addChild(self.menuButton!)
    }
    
    fileprivate func configureLifeIndicator() {
        self.lifeIndicator.position = CGPoint(
            x: self.joystick!.frame.maxX + 2.5 * self.joystick!.joystickRadius,
            y: self.joystick!.frame.minY - self.joystick!.joystickRadius)

        self.lifeIndicator.setLifePoints(self.playerSpaceship!.lifePoints, animated: false)
        
        self.addChild(self.lifeIndicator)
    }
    
    fileprivate func configureScoresNode() {
        self.scoresNode.position = CGPoint(x: kHUDControlMargin/2, y: self.frame.height - 26)
        self.addChild(self.scoresNode)
    }
    
    fileprivate func configureBackground() {
        self.background = BackgroundNode(size: self.size, staticBackgroundImageName: ImageName.GameBackgroundPhone)
        
        self.background!.addLayer(
            imageNames: ["Layer_0_0_iphone", "Layer_0_1_iphone", "Layer_0_2_iphone", "Layer_0_3_iphone", "Layer_0_4_iphone"],
            speed: 0.5)
        
        self.background!.configureInScene(self)
    }
    
    fileprivate func updatePlayerSpaceshipPositionWithJoystickTranslation(_ translation: CGPoint) {
        let translationConstant: CGFloat = 10.0
        
        self.playerSpaceship!.position.x += translationConstant * translation.x
        self.playerSpaceship!.position.y += translationConstant * translation.y
    }
    
    fileprivate func configureHUD() {
        self.configureJoystick()
        self.configureFireButton()
        self.configureLifeIndicator()
        self.configureMenuButton()
        self.configureScoresNode()
    }
    
}


// MARK: - Collision Detection.

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collisionType: CollisionType? = collisionTypeWithContact(contact)
        
        if collisionType == nil {
            
            return
        }
        
        switch collisionType! {
            
        case .playerMissileEnemySpaceship:
            
            // Get the enemy node.
            var enemy: EnemySpaceship
            var missile: Missile
            
            if contact.bodyA.node as? EnemySpaceship != nil {
                
                enemy = contact.bodyA.node as! EnemySpaceship
                missile = contact.bodyB.node as! Missile
            }
            else {
                
                enemy = contact.bodyB.node as! EnemySpaceship
                missile = contact.bodyA.node as! Missile
            }

            // Handle collision.
            self.handleCollisionBetweenPlayerMissile(missile, enemySpaceship: enemy)
            
        case .playerSpaceshipEnemySpaceship:
            
            // Get the enemy node.
            let enemy: EnemySpaceship = contact.bodyA.node as? EnemySpaceship != nil ?
                contact.bodyA.node as! EnemySpaceship :
                contact.bodyB.node as! EnemySpaceship
            
            // Handle collision.
            self.handleCollisionBetweenPlayerSpaceship(playerSpaceship!, enemySpaceship: enemy)
            
        case .enemyMissilePlayerSpaceship:
            
            // Get the enemy node.
            let missile: Missile = contact.bodyA.node as? Missile != nil ?
                contact.bodyA.node as! Missile :
                contact.bodyB.node as! Missile
            
            // Handle collision.
            self.handleCollisionBetweenPlayerSpaceship(playerSpaceship!, enemyMissile: missile)
        }
    }
    
    func collisionTypeWithContact(_ contact: SKPhysicsContact!) -> (CollisionType?) {
        
        let categoryBitmaskBodyA = CategoryBitmask(rawValue: contact.bodyA.categoryBitMask)
        let categoryBitmaskBodyB = CategoryBitmask(rawValue: contact.bodyB.categoryBitMask)

        // Player missile - enemy spaceship.
        if categoryBitmaskBodyA == CategoryBitmask.enemySpaceship &&
            categoryBitmaskBodyB == CategoryBitmask.playerMissile ||
            categoryBitmaskBodyB == CategoryBitmask.enemySpaceship &&
            categoryBitmaskBodyA == CategoryBitmask.playerMissile {
                
            return CollisionType.playerMissileEnemySpaceship
        }
            
        // Player spaceship - enemy spaceship.
        else if categoryBitmaskBodyA == CategoryBitmask.enemySpaceship &&
            categoryBitmaskBodyB == CategoryBitmask.playerSpaceship ||
            categoryBitmaskBodyB == CategoryBitmask.enemySpaceship &&
            categoryBitmaskBodyA == CategoryBitmask.playerSpaceship {
                
            return CollisionType.playerSpaceshipEnemySpaceship
        }
        
        return nil
    }
}


// MARK: - Collision Handling

extension GameScene{

    /// Handle collision between player spaceship and the enemy spaceship.
    fileprivate func handleCollisionBetweenPlayerSpaceship(
        _ playerSpaceship: PlayerSpaceship,
        enemySpaceship: EnemySpaceship!) {
            
        self.increaseScore(ScoreValue.playerMissileHitEnemySpaceship.rawValue)
        
        self.decreasePlayerSpaceshipLifePoints(byValue: LifePointsValue.enemySpaceshipHitPlayerSpaceship.rawValue)
        
        self.decreaseEnemySpaceshipLifePoints(
            byValue: LifePointsValue.enemySpaceshipHitPlayerSpaceship.rawValue,
            enemySpaceship: enemySpaceship)
    }
    
    fileprivate func handleCollisionBetweenPlayerMissile(_ missile: Missile, enemySpaceship: EnemySpaceship) {
        missile.removeFromParent()
        
        self.increaseScore(ScoreValue.playerMissileHitEnemySpaceship.rawValue)
        
        self.decreaseEnemySpaceshipLifePoints(
            byValue: LifePointsValue.playerMissileHitEnemySpaceship.rawValue,
            enemySpaceship: enemySpaceship)

    }
    
    fileprivate func handleCollisionBetweenPlayerSpaceship(_ playerSpaceship: PlayerSpaceship, enemyMissile: Missile) {
        // Not supported.
    }
}



// MARK: - Scores.

extension GameScene {
    
    fileprivate func increaseScore(_ value: Int) {
        self.scoresNode.value += value
    }
    
}


// MARK: - Life points handling.

extension GameScene {
    
    func increasePlayerSpaceshipLifePoints(_ byValue: Int) {
        self.playerSpaceship!.lifePoints += byValue
        self.lifeIndicator.setLifePoints(self.playerSpaceship!.lifePoints, animated: true)
        
        // Add a green color blend for a short moment to indicate the increase of health.
        let colorizeAction = SKAction.colorize(with: UIColor.green,
            colorBlendFactor: 0.7,
            duration: 0.2)
        
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        
        self.playerSpaceship!.run(SKAction.sequence([colorizeAction, uncolorizeAction]))
    }
    
    func decreasePlayerSpaceshipLifePoints(byValue: Int) {
        self.playerSpaceship!.lifePoints += byValue
        self.lifeIndicator.setLifePoints(self.playerSpaceship!.lifePoints, animated: true)

        // Add a red color blend for a short moment to indicate the decrease of health.
        let colorizeAction = SKAction.colorize(with: UIColor.red,
            colorBlendFactor: 0.7,
            duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0,
            duration: 0.2)
        
        self.playerSpaceship!.run(SKAction.sequence([colorizeAction, uncolorizeAction]))
    }
    
    func decreaseEnemySpaceshipLifePoints(byValue: Int, enemySpaceship: EnemySpaceship) {
        enemySpaceship.lifePoints += byValue
        
        // Add a red color blend for a short moment to indicate the decrease of health.
        let colorizeAction = SKAction.colorize(with: UIColor.red,
            colorBlendFactor: 0.7,
            duration: 0.2)
        let uncolorizeAction = SKAction.colorize(withColorBlendFactor: 0.0,
            duration: 0.2)
        
        enemySpaceship.run(SKAction.sequence([colorizeAction, uncolorizeAction]))
    }
    
    func enemyDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        let handler = { (object: AnyObject) -> () in
            let enemySpaceship = object as! EnemySpaceship
            self.destroySpaceship(enemySpaceship)
        }
        
        return handler
    }
    
    func playerDidRunOutOfLifePointsEventHandler() -> DidRunOutOfLifePointsEventHandler {
        let handler = { (object: AnyObject) -> () in
            
            self.destroySpaceship(self.playerSpaceship)
            self.gameSceneDelegate?.gameScene(self, playerDidLoseWithScore: self.scoresNode.value)
        }
        
        return handler
    }
    
    func destroySpaceship(_ spaceship: Spaceship!) {
        
        let explosionEmitter = SKEmitterNode(fileNamed: "Explosion")
        explosionEmitter!.position.x = spaceship.position.x - spaceship.size.width/2
        explosionEmitter!.position.y = spaceship.position.y
        explosionEmitter!.zPosition = spaceship.zPosition + 1
        
        self.addChild(explosionEmitter!)
        
        // Show the explosion.
        explosionEmitter!.run(SKAction.sequence([SKAction.wait(forDuration: 5), SKAction.removeFromParent()]))
        
        // Fade out the enemy and remove it.
        spaceship.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.removeFromParent()]))
        
        // Play explosion sound.
        self.scene!.run(SKAction.playSoundFileNamed(SoundName.Explosion.rawValue, waitForCompletion: false))
    }
    
}
