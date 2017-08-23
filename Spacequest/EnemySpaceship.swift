import SpriteKit


class EnemySpaceship: Spaceship
{
    var missileLaunchTimer: Timer?
    
    
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
        super.init(texture: SKTexture(imageNamed: ImageName.EnemySpaceship.rawValue), color: UIColor.brown, size: size)
        
        self.lifePoints = lifePoints
        
        // Collisions.
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.categoryBitMask = CategoryBitmask.enemySpaceship.rawValue
        self.physicsBody!.collisionBitMask =
            CategoryBitmask.enemySpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue |
            CategoryBitmask.playerSpaceship.rawValue
        
        self.physicsBody!.contactTestBitMask =
            CategoryBitmask.playerSpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue
    }
    
    
    func scheduleRandomMissileLaunch()
    {
        if missileLaunchTimer != nil
        {
            missileLaunchTimer!.invalidate()
        }
        
        let backoffTime = TimeInterval((arc4random() % 3) + 1)


        missileLaunchTimer = Timer(timeInterval: backoffTime, target: self, selector: #selector(EnemySpaceship.launchMissile), userInfo: nil, repeats: false)
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
        
        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        
        missile.run(SKAction.sequence([moveAction, removeAction]))
        
        scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
    
    
    deinit
    {
        if missileLaunchTimer != nil
        {
            missileLaunchTimer!.invalidate()
        }
    }
}
