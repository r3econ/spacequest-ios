import SpriteKit


protocol GameSceneDelegate
{
    func gameSceneDidTapMainMenuButton(gameScene:GameScene)
}


let kHUDControlMargin = 20.0


class GameScene: SKScene
{
    var background: BackgroundNode?
    var playerSpaceship: PlayerSpaceship?
    var joystick: Joystick?
    var fireButton: Button?
    var menuButton: Button?
    var lifeIndicator: LifeIndicator?
    var scoresNode: ScoresNode?
    var launchEnemyTimer: NSTimer?
    var gameSceneDelegate: GameSceneDelegate?

    init(size: CGSize)
    {
        super.init(size: size)

        configureBackground()
        configurePlayerSpaceship()
        configurePhysics()
        configureHUD()
    }
    
    override func didMoveToView(view: SKView)
    {

    }

   
    override func update(currentTime: CFTimeInterval)
    {

    }
    
    
    override var paused: Bool
    {
    didSet
    {
        // Control launching of the enemies.
        if paused != oldValue
        {
            if paused
            {
                stopLaunchingEnemySpaceships()
            }
            else
            {
                startLaunchingEnemySpaceships()
            }
        }
    }
    }
}


/**
Managing enemies.
*/
extension GameScene
{
    func startLaunchingEnemySpaceships()
    {
        scheduleEnemySpaceshipLaunch()
    }
    
    
    func stopLaunchingEnemySpaceships()
    {
        if launchEnemyTimer
        {
            launchEnemyTimer!.invalidate()
        }
    }
    
    
    func scheduleEnemySpaceshipLaunch()
    {
        let randomTimeInterval = NSTimeInterval(arc4random_uniform(3) + 1)

        launchEnemyTimer = NSTimer.scheduledTimerWithTimeInterval(
            randomTimeInterval,
            target: self,
            selector: Selector("launchEnemyTimerFireMethod"),
            userInfo: nil,
            repeats: false)
    }
    
    
    func launchEnemyTimerFireMethod()
    {
        // Launch an enemy.
        launchEnemySpaceship()
        
        // Schedule launch of the next one.
        scheduleEnemySpaceshipLaunch()
    }
    
    
    func launchEnemySpaceship()
    {
        var enemySpaceship = EnemySpaceship(health: 20)
        
        // Determine where to spawn the enemy along the Y axis.
        let minY = enemySpaceship.size.height;
        let maxY = CGRectGetHeight(self.frame) - enemySpaceship.size.height
        let rangeY = maxY - minY
        let randomY: UInt32 = arc4random_uniform(UInt32(rangeY)) + UInt32(minY)
        
        // Set position of the enemy to be slightly off-screen along the right edge,
        // and along a random position along the Y axis.
        enemySpaceship.position = CGPoint(x: frame.size.width + enemySpaceship.size.width/2, y: CGFloat(randomY))
        enemySpaceship.zPosition = self.playerSpaceship!.zPosition
            
        self.addChild(enemySpaceship)
        
        // Determine speed of the enemy.
        let enemyFlightDuration = 4.0
        let moveAction = SKAction.moveToX(-enemySpaceship.size.width/2, duration: enemyFlightDuration)
        
        enemySpaceship.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
}


/**
 Configuration.
*/
extension GameScene
{
    func configurePhysics()
    {
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody.categoryBitMask = CategoryBitmask.ScreenBounds.toRaw()
        self.physicsBody.collisionBitMask = CategoryBitmask.PlayerSpaceship.toRaw()
    }
    
    
    func configurePlayerSpaceship()
    {
        playerSpaceship = PlayerSpaceship()
        
        playerSpaceship!.position = CGPoint(
            x: playerSpaceship!.size.width/2 + 30.0,
            y: CGRectGetHeight(self.frame)/2 + 40.0);
        
        playerSpaceship!.health = 100
        self.addChild(playerSpaceship)
    }
    
    
    func configureJoystick()
    {
        joystick = Joystick(
            maximumRadius: 40.0,
            stickImageNamed: ImageName.JoystickStick.toRaw(),
            baseImageNamed: ImageName.JoystickBase.toRaw());
        
        joystick!.position = CGPoint(
            x: joystick!.size.width,
            y: joystick!.size.height);
        
        
        joystick!.updateHandler =
        {
                (var translation: CGPoint) -> () in
                
                self.updatePlayerSpaceshipPositionWithJoystickTranslation(translation);
        }
        
        self.addChild(joystick!)
    }
    
    
    func configureFireButton()
    {
        fireButton = Button(
            normalImageNamed: ImageName.FireButtonNormal.toRaw(),
            selectedImageNamed: ImageName.FireButtonSelected.toRaw())
        
        fireButton!.position = CGPoint(
            x: CGRectGetWidth(self.frame) - CGRectGetWidth(fireButton!.frame) - kHUDControlMargin,
            y: CGRectGetHeight(fireButton!.frame)/2 + 40.0);
        
        fireButton!.touchUpInsideEventHandler =
        {
            () -> () in
                        
            self.playerSpaceship!.launchMissile()
            return
        }
        
        self.addChild(fireButton!)
    }
    
    
    func configureMenuButton()
    {
        menuButton = Button(
            normalImageNamed: ImageName.ShowMenuButtonNormal.toRaw(),
            selectedImageNamed: ImageName.ShowMenuButtonSelected.toRaw())
        
        menuButton!.position = CGPoint(
            x: CGRectGetWidth(self.frame) - CGRectGetWidth(menuButton!.frame)/2 - 2.0,
            y: CGRectGetHeight(self.frame) - CGRectGetHeight(menuButton!.frame)/2);
        
        menuButton!.touchUpInsideEventHandler =
        {
                () -> () in
                
                self.gameSceneDelegate?.gameSceneDidTapMainMenuButton(self)
                return
        }
        
        self.addChild(menuButton!)
    }
    
    
    func configureLifeIndicator()
    {
        lifeIndicator = LifeIndicator(texture: SKTexture(imageNamed: ImageName.LifeBall.toRaw()))
        lifeIndicator!.position = CGPoint(
            x: CGRectGetMaxX(joystick!.frame) + 2.5 * joystick!.joystickRadius,
            y: CGRectGetMinY(joystick!.frame) - joystick!.joystickRadius)
                
        self.addChild(lifeIndicator!)
    }
    
    
    func configureScoresNode()
    {
        scoresNode = ScoresNode()
        scoresNode!.position = CGPoint(
            x: kHUDControlMargin/2,
            y: CGRectGetHeight(self.frame) - 26)
        
        self.addChild(scoresNode!)
    }
    
    
    func configureBackground()
    {
        background = BackgroundNode(size: self.size, backgroundImageName: ImageName.GameBackgroundPhone)
        background!.configureInScene(self)
    }
    
    
    func updatePlayerSpaceshipPositionWithJoystickTranslation(var translation: CGPoint)
    {
        let translationConstant: CGFloat = 10.0
        
        playerSpaceship!.position.x += translationConstant * translation.x
        playerSpaceship!.position.y += translationConstant * translation.y
    }
    
    
    func configureHUD()
    {
        configureJoystick()
        configureFireButton()
        configureLifeIndicator()
        configureMenuButton()
        configureScoresNode()
    }
}


/**
 Collision Detection.
*/
extension GameScene : SKPhysicsContactDelegate
{
    func didBeginContact(contact: SKPhysicsContact!)
    {
        var collisionType: CollisionType? = collisionTypeWithContact(contact)
        
        if !collisionType
        {
            return
        }
        
        switch collisionType! {
            
        case .PlayerMissileEnemySpaceship:
            
            // Get the enemy node.
            var enemy: EnemySpaceship
            var missile: Missile
            
            if contact.bodyA.node as? EnemySpaceship
            {
                enemy = contact.bodyA.node as EnemySpaceship
                missile = contact.bodyB.node as Missile
            }
            else
            {
                enemy = contact.bodyB.node as EnemySpaceship
                missile = contact.bodyA.node as Missile
            }

            // Handle collision.
            handleCollisionBetweenPlayerMissile(missile, enemySpaceships: enemy)
            
        case .PlayerSpaceshipEnemySpaceship:
            
            // Get the enemy node.
            let enemy: EnemySpaceship = contact.bodyA.node as? EnemySpaceship ?
                contact.bodyA.node as EnemySpaceship :
                contact.bodyB.node as EnemySpaceship
            
            // Handle collision.
            handleCollisionBetweenPlayerSpaceship(playerSpaceship!, enemySpaceship: enemy)
            
        case .EnemyMissilePlayerSpaceship:
            
            // Get the enemy node.
            let missile: Missile = contact.bodyA.node as? Missile ?
                contact.bodyA.node as Missile :
                contact.bodyB.node as Missile
            
            // Handle collision.
            handleCollisionBetweenPlayerSpaceship(playerSpaceship!, enemyMissile: missile)
        }
    }
    
    
    func collisionTypeWithContact(contact: SKPhysicsContact!) -> (collisionType: CollisionType?)
    {
        let categoryBitmaskBodyA = CategoryBitmask.fromRaw(contact.bodyA.categoryBitMask)
        let categoryBitmaskBodyB = CategoryBitmask.fromRaw(contact.bodyB.categoryBitMask)

        // Player missile - enemy spaceship.
        if categoryBitmaskBodyA == CategoryBitmask.EnemySpaceship &&
            categoryBitmaskBodyB == CategoryBitmask.PlayerMissile ||
            categoryBitmaskBodyB == CategoryBitmask.EnemySpaceship &&
            categoryBitmaskBodyA == CategoryBitmask.PlayerMissile
        {
            return CollisionType.PlayerMissileEnemySpaceship
        }
        // Player spaceship - enemy spaceship.
        else if categoryBitmaskBodyA == CategoryBitmask.EnemySpaceship &&
            categoryBitmaskBodyB == CategoryBitmask.PlayerSpaceship ||
            categoryBitmaskBodyB == CategoryBitmask.EnemySpaceship &&
            categoryBitmaskBodyA == CategoryBitmask.PlayerSpaceship
        {
            return CollisionType.PlayerSpaceshipEnemySpaceship
        }
        
        return nil
    }
}


/**
Collision Handling.
*/
extension GameScene
{
    func destroyEnemy(enemy: EnemySpaceship!)
    {
        let explosionEmitter = SKEmitterNode(fileNamed: "Explosion")
        explosionEmitter.position.x = enemy.position.x - enemy.size.width/2
        explosionEmitter.position.y = enemy.position.y
        explosionEmitter.zPosition = enemy.zPosition + 1
        
        self.addChild(explosionEmitter)
        
        // Show the explosion.
        explosionEmitter.runAction(SKAction.sequence([SKAction.waitForDuration(5), SKAction.removeFromParent()]))
    
        // Fade out the enemy and remove it.
        enemy.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.1), SKAction.removeFromParent()]))

        // Play explosion sound.
        scene.runAction(SKAction.playSoundFileNamed(SoundName.Explosion.toRaw(), waitForCompletion: false))
    }
    
    
    /**
     Handle collision between player spaceship and the enemy spaceship.
    */
    func handleCollisionBetweenPlayerSpaceship(
        playerSpaceship: PlayerSpaceship,
        enemySpaceship: EnemySpaceship!)
    {
        destroyEnemy(enemySpaceship)
    }
    
    
    func handleCollisionBetweenPlayerMissile(missile: Missile, enemySpaceships: EnemySpaceship)
    {
        destroyEnemy(enemySpaceships)
        missile.removeFromParent()
    }
    
    
    func handleCollisionBetweenPlayerSpaceship(playerSpaceship: PlayerSpaceship, enemySpaceships: EnemySpaceship!)
    {
        
    }
    
    
    func handleCollisionBetweenPlayerSpaceship(playerSpaceship: PlayerSpaceship, enemyMissile: Missile)
    {
        
    }
}