import SpriteKit


class GameScene: SKScene
{
    var background: BackgroundNode
    var playerSpaceship: PlayerSpaceship
    var joystick: Joystick
    var fireButton: Button
    var launchEnemyTimer: NSTimer?

    init(size: CGSize)
    {
        // Background.
        background = BackgroundNode(size: size)
        
        // Spaceships.
        playerSpaceship = PlayerSpaceship()
        
        // Joystick.
        joystick = Joystick(
            maximumRadius: 40.0,
            stickImageNamed: "joystick_stick",
            baseImageNamed: "joystick_base");
        
        fireButton = Button(
            normalImageNamed: "fire_button_normal",
            selectedImageNamed: "fire_button_selected")
        
        super.init(size: size)
        
        background.configureInScene(self)
        configurePlayerSpaceship()
        configureJoystick()
        configureButtons()
        configurePhysics()
    }
    
    override func didMoveToView(view: SKView)
    {
        startLaunchingEnemySpaceships()
    }

   
    override func update(currentTime: CFTimeInterval)
    {

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
        enemySpaceship.zPosition = self.playerSpaceship.zPosition
            
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
        playerSpaceship.position = CGPoint(
            x: playerSpaceship.size.width/2 + 30.0,
            y: CGRectGetHeight(self.frame)/2 + 40.0);
        
        playerSpaceship.health = 100
        self.addChild(playerSpaceship)
    }
    
    
    func configureJoystick()
    {
        joystick.position = CGPoint(
            x: CGRectGetMaxX(joystick.frame) + 10.0,
            y: CGRectGetHeight(joystick.frame)/2 + 10.0);
        
        joystick.updateHandler =
        {
            (var translation: CGPoint) -> () in
            
            self.updatePlayerSpaceshipPositionWithJoystickTranslation(translation);
        }
        
        self.addChild(joystick)
    }
    
    
    func configureButtons()
    {
        fireButton.position = CGPoint(
            x: CGRectGetWidth(self.frame) - CGRectGetWidth(fireButton.frame) - 10.0,
            y: CGRectGetHeight(fireButton.frame)/2 + 40.0);
        
        fireButton.touchUpInsideEventHandler =
        {
            () -> () in
                        
            self.playerSpaceship.launchMissile()
        }
        
        self.addChild(fireButton)
    }
    
    
    func updatePlayerSpaceshipPositionWithJoystickTranslation(var translation: CGPoint)
    {
        let translationConstant: CGFloat = 10.0
        
        playerSpaceship.position.x += translationConstant * translation.x
        playerSpaceship.position.y += translationConstant * translation.y
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
            let enemy: EnemySpaceship = contact.bodyA.node as? EnemySpaceship ?
                contact.bodyA.node as EnemySpaceship :
                contact.bodyB.node as EnemySpaceship

            // Handle collision.
            handlePlayerMissileEnemySpaceshipsCollision(enemy)
            
        case .PlayerSpaceshipEnemySpaceship:
            
            // Get the enemy node.
            let enemy: EnemySpaceship = contact.bodyA.node as? EnemySpaceship ?
                contact.bodyA.node as EnemySpaceship :
                contact.bodyB.node as EnemySpaceship
            
            // Handle collision.
            handlePlayerEnemySpaceshipsCollision(enemy)
            
        case .EnemyMissilePlayerSpaceship:
            
            // Get the enemy node.
            let enemy: EnemySpaceship = contact.bodyA.node as? EnemySpaceship ?
                contact.bodyA.node as EnemySpaceship :
                contact.bodyB.node as EnemySpaceship
            
            // Handle collision.
            handlePlayerSpaceshipEnemyMissileCollision(enemy)
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
        
    }
    
    
    func handlePlayerEnemySpaceshipsCollision(enemy: EnemySpaceship!)
    {
        
    }
    
    
    func handlePlayerMissileEnemySpaceshipsCollision(enemy: EnemySpaceship!)
    {
        
    }
    
    
    func handlePlayerSpaceshipEnemyMissileCollision(enemy: EnemySpaceship!)
    {
        
    }
}