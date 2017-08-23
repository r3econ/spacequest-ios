import SpriteKit

class Missile: SKSpriteNode {
    
    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    convenience init() {
        let size = CGSize(width: 10.0, height: 10.0)
        
        self.init(texture: SKTexture(imageNamed:ImageName.Missile.rawValue),
            color: UIColor.brown,
            size: size)
        
        self.name = NSStringFromClass(Missile.self)

        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        self.physicsBody!.usesPreciseCollisionDetection = true
    }
    class func enemyMissile() -> Missile {
        let missile = Missile()
        missile.physicsBody!.categoryBitMask = CategoryBitmask.enemyMissile.rawValue
        missile.physicsBody!.contactTestBitMask = CategoryBitmask.playerSpaceship.rawValue
        
        return missile
    }
    class func playerMissile() -> Missile {
        let missile = Missile()
        missile.physicsBody!.categoryBitMask = CategoryBitmask.playerMissile.rawValue
        missile.physicsBody!.contactTestBitMask = CategoryBitmask.enemySpaceship.rawValue
        
        return missile
    }
    
}
