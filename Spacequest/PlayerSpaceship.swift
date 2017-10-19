import CoreGraphics
import SpriteKit

class PlayerSpaceship: Spaceship {
    
    fileprivate let engineBurstEmitter = SKEmitterNode(fileNamed: "PlayerSpaceshipEngineBurst")!
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init() {
        let size = CGSize(width: 64, height: 50)
        
        self.init(texture: SKTexture(imageNamed: ImageName.PlayerSpaceship.rawValue),
                  color: UIColor.brown,
                  size: size)
        
        self.name = NSStringFromClass(PlayerSpaceship.self)
        
        self.configureCollisions()
        self.configureEngineBurst()
    }
    
    // MARK: - Configuration

    fileprivate func configureCollisions() {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.allowsRotation = false
        
        self.physicsBody!.categoryBitMask = CategoryBitmask.playerSpaceship.rawValue
        self.physicsBody!.collisionBitMask =
            CategoryBitmask.enemyMissile.rawValue |
            CategoryBitmask.screenBounds.rawValue
        
        self.physicsBody!.contactTestBitMask =
            CategoryBitmask.enemySpaceship.rawValue |
            CategoryBitmask.enemyMissile.rawValue
    }
    
    fileprivate func configureEngineBurst() {
        self.engineBurstEmitter.position = CGPoint(x: -self.size.width/2 - 5.0, y: 0.0)
        self.addChild(self.engineBurstEmitter)
    }

    // MARK: - Special actions
    
    func launchMissile() {
        // Create a missile
        let missile = Missile.playerMissile()
        missile.position = CGPoint(x: self.frame.maxX + 10.0, y: position.y)
        missile.zPosition = self.zPosition - 1
        
        // Place it in the scene
        self.scene!.addChild(missile)
        
        // Make it move
        let velocity: CGFloat = 600.0
        let moveDuration = scene!.size.width / velocity
        let missileEndPosition = CGPoint(x: position.x + scene!.size.width, y: position.y)
        
        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveAction, removeAction]))
        
        // Play sound
        self.scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
    
}
