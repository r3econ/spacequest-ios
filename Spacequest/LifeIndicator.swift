import SpriteKit


class LifeIndicator: SKSpriteNode
{
    var titleLabelNode: SKLabelNode?

    
    required init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }

    
    init(texture: SKTexture!)
    {
        lifePoints = 100
        
        super.init(texture: texture,
            color: nil,
            size: texture.size())
        
        titleLabelNode = SKLabelNode(fontNamed: FontName.Wawati.toRaw())
        titleLabelNode!.fontSize = 14.0
        titleLabelNode!.fontColor = UIColor(white: 1.0, alpha: 0.7)
        titleLabelNode!.horizontalAlignmentMode = .Center
        titleLabelNode!.verticalAlignmentMode = .Center

        update(animated: false)
        
        self.addChild(titleLabelNode)
    }
    
    
    var lifePoints: Int = 0
    {
    
    didSet
    {
        update(animated: false)
    }
    
    }
    
    
    func setLifePoints(points: Int, animated: Bool)
    {
        lifePoints = points
        
        update(animated: animated)
    }
    
    
    func update(#animated: Bool)
    {
        titleLabelNode!.text = "\(lifePoints)"
        
        let blendColor = lifeBallColor()
        let blendFactor: CGFloat = 1.0
        
        if animated
        {
            let colorizeAction = SKAction.colorizeWithColor(blendColor, colorBlendFactor: blendFactor, duration: 0.2)
            let scaleUpAction = SKAction.scaleBy(1.2, duration: 0.2)
            let scaleActionSequence = SKAction.sequence([scaleUpAction, scaleUpAction.reversedAction()])
            
            titleLabelNode!.color = blendColor
            titleLabelNode!.colorBlendFactor = blendFactor
            
            self.runAction(SKAction.group([colorizeAction, scaleActionSequence]))
        }
        else
        {
            self.color = blendColor
            self.colorBlendFactor = blendFactor
            titleLabelNode!.color = blendColor
            titleLabelNode!.colorBlendFactor = blendFactor
        }
    }
    
    
    func lifeBallColor() -> UIColor
    {
        var fullBarColorR: CGFloat = 0.0, fullBarColorG: CGFloat = 0.0, fullBarColorB: CGFloat = 0.0, fullBarColorAlpha: CGFloat = 0.0
        var emptyBarColorR: CGFloat = 0.0, emptyBarColorG: CGFloat = 0.0, emptyBarColorB: CGFloat = 0.0, emptyBarColorAlpha: CGFloat = 0.0
        
        UIColor.greenColor().getRed(&fullBarColorR, green: &fullBarColorG, blue: &fullBarColorB, alpha: &fullBarColorAlpha)
        UIColor.redColor().getRed(&emptyBarColorR, green: &emptyBarColorG, blue: &emptyBarColorB, alpha: &emptyBarColorAlpha)

        let resultColorR = emptyBarColorR + CGFloat(lifePoints)/100 * (fullBarColorR - emptyBarColorR)
        let resultColorG = emptyBarColorG + CGFloat(lifePoints)/100 * (fullBarColorG - emptyBarColorG)
        let resultColorB = emptyBarColorB + CGFloat(lifePoints)/100 * (fullBarColorB - emptyBarColorB)

        return UIColor(red: resultColorR, green: resultColorG, blue: resultColorB, alpha: 1.0)
    }
}