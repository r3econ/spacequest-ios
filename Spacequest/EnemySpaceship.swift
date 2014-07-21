import SpriteKit


class EnemySpaceship: Spaceship
{
    var missileLaunchTimer: NSTimer?
    
    
    init(health: Int)
    {
        super.init(texture: SKTexture(imageNamed: ImageName.EnemySpaceship.toRaw()), color: nil, size: CGSize(width: 36, height: 31))
        
        self.health = health
    }
    
    
    func scheduleRandomMissileLaunch()
    {
        if missileLaunchTimer
        {
            missileLaunchTimer!.invalidate()
        }
        
        var backoffTime = NSTimeInterval((arc4random() % 3) + 1)


        missileLaunchTimer = NSTimer(timeInterval: backoffTime, target: self, selector: "launchMissile", userInfo: nil, repeats: false)
    }
    
    
    func launchMissile()
    {
        var missile = Missile.enemyMissile()
        
        missile.position = position
        missile.zPosition = zPosition - 1
        
        scene.addChild(missile)
        
        var velocity: CGFloat = 600.0
        var moveDuration = scene.size.width / velocity
        var missileEndPosition = CGPoint(x: -0.1 * scene.size.width, y: position.y)
        
        var moveAction = SKAction.moveTo(missileEndPosition, duration: NSTimeInterval(moveDuration))
        var removeAction = SKAction.removeFromParent()
        
        missile.runAction(SKAction.sequence([moveAction, removeAction]))
        
        scene.runAction(SKAction.playSoundFileNamed(SoundName.MissileLaunch.toRaw(), waitForCompletion: false))
    }
    
    
    deinit
    {
        if missileLaunchTimer
        {
            missileLaunchTimer!.invalidate()
        }
    }
}