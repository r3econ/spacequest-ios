import SpriteKit


class LifeIndicator: SKSpriteNode
{
    var titleLabelNode: SKLabelNode?

    init(texture: SKTexture!)
    {
        super.init(texture: texture,
            color: nil,
            size: CGSizeZero)
        
        titleLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        titleLabelNode!.horizontalAlignmentMode = .Center
        titleLabelNode!.verticalAlignmentMode = .Center
        titleLabelNode!.color = UIColor.whiteColor()
        
        self.addChild(titleLabelNode)
    }
    
    func setValue(var value:Int)
    {
        titleLabelNode!.text = "\(value)%"
    }
}