import SpriteKit

class BackgroundNode: SKEffectNode
{
    var backgroundGradient: SKSpriteNode
    var stardustEmitter: SKEmitterNode?

    init(size: CGSize)
    {
        var backgroundImageName = ImageName.BackgroundGradientPad
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            backgroundImageName = ImageName.BackgroundGradientPhone
        }
        
        backgroundGradient = SKSpriteNode(imageNamed: backgroundImageName.toRaw())
        backgroundGradient.size = size
        
        super.init()
        
        self.addChild(backgroundGradient)
        
        configureStarDustEmitter()
    }
    
    
    func configureInScene(scene: SKScene)
    {
        position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        zPosition = -1000
        
        scene.addChild(self)
    }
    
    
    func configureStarDustEmitter()
    {
        stardustEmitter = SKEmitterNode(fileNamed: "StarDustParticle")
        stardustEmitter!.position = CGPoint(x: backgroundGradient.size.width/2 + 5.0, y: 0.0)
        
        self.addChild(stardustEmitter)
    }
}