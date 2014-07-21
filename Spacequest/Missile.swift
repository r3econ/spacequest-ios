import SpriteKit


class Missile: SKSpriteNode
{
    init()
    {
        var size = CGSizeMake(10.0, 10.0)
        super.init(texture: SKTexture(imageNamed:ImageName.Missile.toRaw()),
            color: nil,
            size: size)
        
        name = NSStringFromClass(Missile.self)

        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody.usesPreciseCollisionDetection = true
    }
    
    
    class func enemyMissile() -> Missile
    {
        var missile = Missile()
        
        missile.physicsBody.categoryBitMask = CategoryBitmask.EnemyMissile.toRaw()
        missile.physicsBody.contactTestBitMask = CategoryBitmask.PlayerSpaceship.toRaw()
        
        return missile
    }
    
    
    class func playerMissile() -> Missile
    {
        var missile = Missile()
        
        missile.physicsBody.categoryBitMask = CategoryBitmask.PlayerMissile.toRaw()
        missile.physicsBody.contactTestBitMask = CategoryBitmask.EnemySpaceship.toRaw()
        
        return missile
    }
}
