import SpriteKit


class EnemySpaceship: Spaceship
{
    var missileLaunchTimer: NSTimer?
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    required init(texture: SKTexture!, color: UIColor!, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    
    
    init(lifePoints: Int)
    {
        let size = CGSize(width: 36, height: 31)
        super.init(texture: SKTexture(imageNamed: ImageName.EnemySpaceship.rawValue), color: nil, size: size)
        
        self.lifePoints = lifePoints
        
        // Collisions.
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.categoryBitMask = CategoryBitmask.EnemySpaceship.rawValue
        self.physicsBody!.collisionBitMask =
            CategoryBitmask.EnemySpaceship.rawValue |
            CategoryBitmask.PlayerMissile.rawValue |
            CategoryBitmask.PlayerSpaceship.rawValue
        
        self.physicsBody!.contactTestBitMask =
            CategoryBitmask.PlayerSpaceship.rawValue |
            CategoryBitmask.PlayerMissile.rawValue
    }
    
    
    func scheduleRandomMissileLaunch()
    {
        if missileLaunchTimer != nil
        {
            missileLaunchTimer!.invalidate()
        }
        
        var backoffTime = NSTimeInterval((arc4random() % 3) + 1)


        missileLaunchTimer = NSTimer(timeInterval: backoffTime, target: self, selector: "launchMissile", userInfo: nil, repeats: false)
    }
    
    
    func launchMissile()
    {
        var missile = Missile.enemyMissile()
        
        missile.position = position
        missile.zPosition = zPosition - 1
        
        scene!.addChild(missile)
        
        var velocity: CGFloat = 600.0
        var moveDuration = scene!.size.width / velocity
        var missileEndPosition = CGPoint(x: -0.1 * scene!.size.width, y: position.y)
        
        var moveAction = SKAction.moveTo(missileEndPosition, duration: NSTimeInterval(moveDuration))
        var removeAction = SKAction.removeFromParent()
        
        missile.runAction(SKAction.sequence([moveAction, removeAction]))
        
        scene!.runAction(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
    
    
    deinit
    {
        if missileLaunchTimer != nil
        {
            missileLaunchTimer!.invalidate()
        }
    }
}