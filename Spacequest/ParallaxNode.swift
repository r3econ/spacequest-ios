import SpriteKit

class ParallaxLayer: NSObject
{
    var speed = 0.0
    var imageNames: [String]
    
    init(imageNames: [String])
    {
        self.imageNames = imageNames
    }
}


class ParallaxNode: SKEffectNode
{
    var staticBackgroundNode: SKSpriteNode
    var layers: [ParallaxLayer]?
    
    init(size: CGSize, staticBackgroundImageName: ImageName)
    {
        staticBackgroundNode = SKSpriteNode(imageNamed: staticBackgroundImageName.toRaw())
        staticBackgroundNode.size = size
        
        super.init()
        
        self.addChild(staticBackgroundNode)
    }
    
    
    func configureInScene(scene: SKScene)
    {
        position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        zPosition = -1000
        
        scene.addChild(self)
    }
}