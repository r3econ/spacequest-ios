import SpriteKit


class EnemySpaceship: Spaceship
{
    var missileLaunchTimer: NSTimer?
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    required init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    
    
    init(lifePoints: Int)
    {
        let size = CGSize(width: 36, height: 31)
        super.init(texture: SKTexture(imageNamed: ImageName.EnemySpaceship.rawValue), color: UIColor.brownColor(), size: size)
        
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
        
        let backoffTime = NSTimeInterval((arc4random() % 3) + 1)


        missileLaunchTimer = NSTimer(timeInterval: backoffTime, target: self, selector: "launchMissile", userInfo: nil, repeats: false)
    }
    
    
    func launchMissile()
    {
        let missile = Missile.enemyMissile()
        
        missile.position = position
        missile.zPosition = zPosition - 1
        
        scene!.addChild(missile)
        
        let velocity: CGFloat = 600.0
        let moveDuration = scene!.size.width / velocity
        let missileEndPosition = CGPoint(x: -0.1 * scene!.size.width, y: position.y)
        
        let moveAction = SKAction.moveTo(missileEndPosition, duration: NSTimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        
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