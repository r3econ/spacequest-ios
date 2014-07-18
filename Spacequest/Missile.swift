import SpriteKit


class Missile: SKSpriteNode {
   
    init()
    {
        super.init(texture: SKTexture(imageNamed:ImageName.Missile.toRaw()),
            color: nil,
            size: CGSizeZero)
        
        name = "Missile"
        physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.collisionBitMask = 0
    }
    
    
    class func enemyMissile() -> Missile {
        
        var missile = Missile()
        
        missile.physicsBody.categoryBitMask = CategoryBitmask.EnemyMissile.toRaw()
        missile.physicsBody.contactTestBitMask = CategoryBitmask.PlayerSpaceship.toRaw()
        
        return missile
    }
    
    
    class func playerMissile() -> Missile {
        
        var missile = Missile()
        
        missile.physicsBody.categoryBitMask = CategoryBitmask.PlayerMissile.toRaw()
        missile.physicsBody.contactTestBitMask = CategoryBitmask.EnemySpaceship.toRaw()
        
        return missile
    }
}
