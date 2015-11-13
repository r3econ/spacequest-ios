import SpriteKit


class Missile: SKSpriteNode
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    required override init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    
    
    convenience init()
    {
        let size = CGSizeMake(10.0, 10.0)
        self.init(texture: SKTexture(imageNamed:ImageName.Missile.rawValue),
            color: UIColor.brownColor(),
            size: size)
        
        name = NSStringFromClass(Missile.self)

        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody!.usesPreciseCollisionDetection = true
    }
    
    
    class func enemyMissile() -> Missile
    {
        let missile = Missile()
        
        missile.physicsBody!.categoryBitMask = CategoryBitmask.EnemyMissile.rawValue
        missile.physicsBody!.contactTestBitMask = CategoryBitmask.PlayerSpaceship.rawValue
        
        return missile
    }
    
    
    class func playerMissile() -> Missile
    {
        let missile = Missile()
        
        missile.physicsBody!.categoryBitMask = CategoryBitmask.PlayerMissile.rawValue
        missile.physicsBody!.contactTestBitMask = CategoryBitmask.EnemySpaceship.rawValue
        
        return missile
    }
}
