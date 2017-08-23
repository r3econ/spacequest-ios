import SpriteKit

extension Array {
    
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in self.enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        
        return nil
    }
    
}

class ParallaxLayerAttributes: NSObject {
    var speed : CGFloat = 0.0
    var imageNames: [String]
    
    init(imageNames: [String], speed: CGFloat = 0.0) {
        self.imageNames = imageNames
        self.speed = speed
    }
}


class ParallaxNode: SKEffectNode {
    
    var staticBackgroundNode: SKSpriteNode?
    var layerNodes: [[SKSpriteNode]] = []
    var layerAttributes: [ParallaxLayerAttributes] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: CGSize, staticBackgroundImageName: ImageName) {
        self.staticBackgroundNode = SKSpriteNode(imageNamed: staticBackgroundImageName.rawValue)
        self.staticBackgroundNode!.size = size
        
        super.init()
        
        self.addChild(self.staticBackgroundNode!)
    }
    
    func addLayer(imageNames: [String], speed: CGFloat = 0.0) {
        let layerAttributes = ParallaxLayerAttributes(imageNames: imageNames, speed: speed)
        
        configureLayerNodes(layerAttributes)
    }
    
    func configureInScene(_ scene: SKScene) {
        self.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        self.zPosition = -1000
        
        scene.addChild(self)
    }
    
    func configureLayerNodes(_ attributes: ParallaxLayerAttributes) {        
        var spriteNodes: [SKSpriteNode] = []
        
        for index in 0 ..< attributes.imageNames.count {
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
                    x: previousSpriteNode.frame.maxX + newSpriteNode.size.width/2,
                    y: 0)
            }
            
            spriteNodes.append(newSpriteNode)
            
            // Only add first two nodes.
            if (index == 0) || (index == 1)
            {
                self.addChild(newSpriteNode)
            }
        }
        
        self.layerNodes.append(spriteNodes)
        self.layerAttributes.append(attributes)
    }
    
    func update(_ currentTime: CFTimeInterval) {
        for i in 0 ..< self.layerNodes.count {
            let speed = self.layerAttributes[i].speed
            var layer = self.layerNodes[i]
            
            for j in 0 ..< layer.count
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
    
    func reposition(_ nodeToReposition: SKSpriteNode, inLayer: inout [SKSpriteNode]) {
        // Calculate index of the node that we're gonna reposition.
        // Now it's on the left on the screen.
        let nodeToRepositionIndex = inLayer.find{ $0 == nodeToReposition }!
        
        // Calculate index of the currently last node in the queue to show.
        // This node is now on the right on the screen.
        var lastNodeIndex = nodeToRepositionIndex + inLayer.count - 1
        
        if lastNodeIndex >= inLayer.count {
            lastNodeIndex -= inLayer.count
        }
        
        // Calculate index of the the node that is going to appear from the right.
        var appearingNodeIndex = nodeToRepositionIndex + 2
        
        if appearingNodeIndex >= inLayer.count {
            appearingNodeIndex -= inLayer.count
        }
        
        //println("Current node idx: \(nodeToRepositionIndex), Last: \(lastNodeIndex)")

        let lastNode: SKSpriteNode! = inLayer[lastNodeIndex]
        let appearingNode: SKSpriteNode! = inLayer[appearingNodeIndex]
        
        let newPosition = CGPoint(
            x: lastNode.frame.maxX + nodeToReposition.size.width/2,
            y: 0)
        
        //println("New position: \(newPosition)")
        
        // Remove the moved node from the screen.
        if nodeToReposition !== appearingNode {
            nodeToReposition.removeFromParent()
        }
        
        if appearingNode!.parent == nil {
            self.addChild(appearingNode)
        }
        
        // Move the first node to the end.
        nodeToReposition.position = newPosition;
    }
    
}
