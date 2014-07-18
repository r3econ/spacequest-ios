import CoreGraphics
import SpriteKit


class PlayerSpaceship: Spaceship
{
    init()
    {
        super.init(texture: SKTexture(imageNamed: ImageName.PlayerSpaceship.toRaw()),
            color: nil,
            size: CGSize(width: 64, height: 50))
    }
    
    
    func launchMissile()
    {
        var missile = Missile.playerMissile()
        
        missile.position = CGPoint(x: position.x + 80.0, y: position.y)
        missile.zPosition = zPosition - 1
    
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