import SpriteKit


extension Array
{
    func find(includedElement: Element -> Bool) -> Int?
    {
        for (idx, element) in self.enumerate()
        {
            if includedElement(element)
            {
                return idx
            }
        }
        
        return nil
    }
}



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
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    init(size: CGSize, staticBackgroundImageName: ImageName)
    {
        staticBackgroundNode = SKSpriteNode(imageNamed: staticBackgroundImageName.rawValue)
        staticBackgroundNode!.size = size
        
        super.init()
        
        self.addChild(staticBackgroundNode!)
    }
    
    
    func addLayer(imageNames imageNames: [String], speed: CGFloat = 0.0)
    {
        let layerAttributes = ParallaxLayerAttributes(imageNames: imageNames, speed: speed)
        
        configureLayerNodes(layerAttributes)
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
            
            // Place first node.
            if index == 0
            {
                newSpriteNode.position = CGPoint(
                    x: self.frame.size.width/2,
                    y: 0)
            }
            // Place next node.
            else
            {
                let previousSpriteNode = spriteNodes[index - 1]
                
                newSpriteNode.position = CGPoint(
                    x: CGRectGetMaxX(previousSpriteNode.frame) + newSpriteNode.size.width/2,
                    y: 0)
            }
            
            spriteNodes.append(newSpriteNode)
            
            // Only add first two nodes.
            if (index == 0) || (index == 1)
            {
                self.addChild(newSpriteNode)
            }
        }
        
        layerNodes.append(spriteNodes)
        layerAttributes.append(attributes)
    }
    
    
    func update(currentTime: CFTimeInterval)
    {
        for var i = 0; i < layerNodes.count; ++i
        {
            let speed = layerAttributes[i].speed
            var layer = layerNodes[i]
            
            for var j = 0; j < layer.count; ++j
            {
                let node = layer[j]
                
                // Move the node left.
                node.position.x -= speed
                
                // Check if the node should be repositioned.
                let terminalPosition = CGPoint(
                    x: -node.size.width,
                    y: 0.0)
                
                if node.position.x <= terminalPosition.x
                {
                    // Reposition the node.
                    reposition(node, inLayer: &layer)
                    break
                }
                
            }
        }
    }
    
    
    func reposition(nodeToReposition: SKSpriteNode, inout inLayer: [SKSpriteNode])
    {
        // Calculate index of the node that we're gonna reposition.
        // Now it's on the left on the screen.
        let nodeToRepositionIndex = inLayer.find{ $0 == nodeToReposition }!
        
        // Calculate index of the currently last node in the queue to show.
        // This node is now on the right on the screen.
        var lastNodeIndex = nodeToRepositionIndex + inLayer.count - 1
        
        if lastNodeIndex >= inLayer.count
        {
            lastNodeIndex -= inLayer.count
        }
        
        // Calculate index of the the node that is going to appear from the right.
        var appearingNodeIndex = nodeToRepositionIndex + 2
        
        if appearingNodeIndex >= inLayer.count
        {
            appearingNodeIndex -= inLayer.count
        }
        
        //println("Current node idx: \(nodeToRepositionIndex), Last: \(lastNodeIndex)")

        let lastNode: SKSpriteNode! = inLayer[lastNodeIndex]
        let appearingNode: SKSpriteNode! = inLayer[appearingNodeIndex]
        
        let newPosition = CGPoint(
            x: CGRectGetMaxX(lastNode.frame) + nodeToReposition.size.width/2,
            y: 0)
        
        //println("New position: \(newPosition)")
        
        // Remove the moved node from the screen.
        if nodeToReposition !== appearingNode
        {
            nodeToReposition.removeFromParent()
        }
        
        if appearingNode!.parent == nil
        {
            self.addChild(appearingNode)
        }
        
        // Move the first node to the end.
        nodeToReposition.position = newPosition;
    }
}