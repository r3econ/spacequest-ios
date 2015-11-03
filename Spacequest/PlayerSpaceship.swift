import CoreGraphics
import SpriteKit


class PlayerSpaceship: Spaceship
{
    var engineBurstEmitter: SKEmitterNode?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    required init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    
    
    convenience init()
    {
        let size = CGSize(width: 64, height: 50)
        
        self.init(texture: SKTexture(imageNamed: ImageName.PlayerSpaceship.rawValue),
            color: UIColor.brownColor(),
            size: size)

        name = NSStringFromClass(PlayerSpaceship.self)
        
        // Collisions.
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.allowsRotation = false

        self.physicsBody!.categoryBitMask = CategoryBitmask.PlayerSpaceship.rawValue
        self.physicsBody!.collisionBitMask =
            CategoryBitmask.EnemyMissile.rawValue |
            CategoryBitmask.ScreenBounds.rawValue
        
        self.physicsBody!.contactTestBitMask =
            CategoryBitmask.EnemySpaceship.rawValue |
            CategoryBitmask.EnemyMissile.rawValue
        
        configureEngineBurstEmitter()
    }
    
    
    func configureEngineBurstEmitter()
    {
        engineBurstEmitter = SKEmitterNode(fileNamed: "PlayerSpaceshipEngineBurst")
        engineBurstEmitter!.position = CGPoint(x: -self.size.width/2 - 5.0, y: 0.0)
        
        self.addChild(engineBurstEmitter!)
    }
    
    
    func launchMissile()
    {
        let missile = Missile.playerMissile()
        
        missile.position = CGPoint(x: CGRectGetMaxX(self.frame) + 10.0, y: position.y)
        missile.zPosition = self.zPosition - 1
    
        scene!.addChild(missile)
        
        let velocity: CGFloat = 600.0
        let moveDuration = scene!.size.width / velocity
        let missileEndPosition = CGPoint(x: position.x + scene!.size.width, y: position.y)
        
        let moveAction = SKAction.moveTo(missileEndPosition, duration: NSTimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        
        missile.runAction(SKAction.sequence([moveAction, removeAction]))
        
        scene!.runAction(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
}