import SpriteKit


class ParallaxLayerAttributes: NSObject
{
    var speed : CGFloat = 0.0
    var imageNames: [String]
    
    init(imageNames: [String], speed: CGFloat = 0.0)
    {
        self.imageNames = imageNames
        self.speed = speed
    }
}


class ParallaxNode: SKEffectNode
{
    var staticBackgroundNode: SKSpriteNode?
    var layerNodes: [[SKSpriteNode]] = []
    var layerAttributes: [ParallaxLayerAttributes] = []
    
    required init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    
    init(size: CGSize, staticBackgroundImageName: ImageName)
    {
        staticBackgroundNode = SKSpriteNode(imageNamed: staticBackgroundImageName.toRaw())
        staticBackgroundNode!.size = size
        
        super.init()
        
        self.addChild(staticBackgroundNode)
    }
    
    
    func addLayer(#imageNames: [String], speed: CGFloat = 0.0)
    {
        let layer = ParallaxLayerAttributes(imageNames: imageNames, speed: speed)
        
        configureLayerNodes(layer)
    }
    
    
    func configureInScene(scene: SKScene)
    {
        position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        zPosition = -1000
        
        scene.addChild(self)
    }
    
    
    func configureLayerNodes(attributes: ParallaxLayerAttributes)
    {
        var position = CGPointZero
        
        var spriteNodes: [SKSpriteNode] = []
        
        for var index = 0; index < attributes.imageNames.count; ++index
        {
            let imageName = attributes.imageNames[index]
            let newSpriteNode = SKSpriteNode(imageNamed: imageName)
            
            // Place first image.
            if index == 0
            {
                newSpriteNode.position = CGPoint(
                    x:-100 + self.frame.size.width/2,
                    y: 0)
            }
            // Place next image.
            else
            {
                let previousSpriteNode = spriteNodes[index - 1]
                
                newSpriteNode.position = CGPoint(
                    x: CGRectGetMaxX(previousSpriteNode.frame) + 5.0 + newSpriteNode.size.width/2,
                    y: 0)
            }
            
            spriteNodes.append(newSpriteNode)
            self.addChild(newSpriteNode)
        }
        
        layerNodes.append(spriteNodes)
        layerAttributes.append(attributes)
    }
    
    
    func startScrolling()
    {
        for var index = 0; index < layerNodes.count; ++index
        {
            let speed = layerAttributes[index].speed
            let layer = layerNodes[index]
            
            for node in layer
            {
                scrollNode(node, inLayer: layer, shouldScheduleRepositioning: true)
            }
        }
    }
    
    
    func scrollNode(node: SKSpriteNode, inLayer:[SKSpriteNode], shouldScheduleRepositioning: Bool)
    {
        let moveDuration = (node.size.width + node.position.x) / CGFloat(speed)
        let destination = CGPoint(
            x: -node.size.width,
            y: 0.0)
        
        let scrollAction = SKAction.moveTo(destination, duration: NSTimeInterval(moveDuration))
        
        if shouldScheduleRepositioning
        {
            let completionAction = SKAction.runBlock(
                {
                    () -> () in
                    
                    self.repositionFirstNodeInLayer(inLayer)
                    self.scrollNode(node, inLayer: inLayer, shouldScheduleRepositioning: true)
            })
            
            node.runAction(SKAction.sequence([scrollAction, completionAction]))
        }
    }
    
    
    func repositionFirstNodeInLayer(layer: [SKSpriteNode])
    {
        let firstNode: SKSpriteNode! = layer.first
        let lastNode: SKSpriteNode! = layer.last
        layer.append(firstNode)
        
        
        // Move the first node to the end.
        firstNode.position = CGPoint(
            x: CGRectGetMaxX(lastNode.frame) + 5.0 + firstNode.size.width/2,
            y: 0)
        
    }
}