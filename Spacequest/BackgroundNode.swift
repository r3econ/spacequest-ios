import SpriteKit

class BackgroundNode: SKEffectNode
{
    var backgroundGradient: SKSpriteNode
    
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
    }
    
    
    func configureInScene(scene: SKScene)
    {
        position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        zPosition = -1000
        
        scene.addChild(self)
    }
}