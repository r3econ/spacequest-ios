import CoreGraphics
import SpriteKit


class PlayerSpaceship: Spaceship
{
    init()
    {
        let size = CGSize(width: 64, height: 50)
        
        super.init(texture: SKTexture(imageNamed: ImageName.PlayerSpaceship.toRaw()),
            color: nil,
            size: size)

        name = NSStringFromClass(PlayerSpaceship.self)
        
        // Collisions.
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody.usesPreciseCollisionDetection = true

        self.physicsBody.categoryBitMask = CategoryBitmask.PlayerSpaceship.toRaw()
        self.physicsBody.collisionBitMask =
            CategoryBitmask.EnemySpaceship.toRaw() |
            CategoryBitmask.EnemyMissile.toRaw() |
            CategoryBitmask.ScreenBounds.toRaw()
        
        self.physicsBody.contactTestBitMask =
            CategoryBitmask.EnemySpaceship.toRaw() |
            CategoryBitmask.EnemyMissile.toRaw()
    }
    
    
    func launchMissile()
    {
        var missile = Missile.playerMissile()
        
        missile.position = CGPoint(x: CGRectGetMaxX(self.frame) + 10.0, y: position.y)
        missile.zPosition = self.zPosition - 1
    
        scene.addChild(missile)
        
        var velocity: CGFloat = 600.0
        var moveDuration = scene.size.width / velocity
        var missileEndPosition = CGPoint(x: position.x + scene.size.width, y: position.y)
        
        var moveAction = SKAction.moveTo(missileEndPosition, duration: NSTimeInterval(moveDuration))
        var removeAction = SKAction.removeFromParent()
        
        missile.runAction(SKAction.sequence([moveAction, removeAction]))
        
        scene.runAction(SKAction.playSoundFileNamed(SoundName.MissileLaunch.toRaw(), waitForCompletion: false))
    }
}