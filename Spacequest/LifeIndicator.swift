import SpriteKit


class LifeIndicator: SKSpriteNode
{
    var titleLabelNode: SKLabelNode?

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
    
    var lifePoints: Int
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
        let blendFactor = 1.0
        
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
        var fullBarColorR = 0.0, fullBarColorG = 0.0, fullBarColorB = 0.0, fullBarColorAlpha  = 0.0
        var emptyBarColorR = 0.0, emptyBarColorG = 0.0, emptyBarColorB = 0.0, emptyBarColorAlpha = 0.0
        
        UIColor.greenColor().getRed(&fullBarColorR, green: &fullBarColorG, blue: &fullBarColorB, alpha: &fullBarColorAlpha)
        UIColor.redColor().getRed(&emptyBarColorR, green: &emptyBarColorG, blue: &emptyBarColorB, alpha: &emptyBarColorAlpha)

        let resultColorR = emptyBarColorR + Double(lifePoints)/100 * (fullBarColorR - emptyBarColorR)
        let resultColorG = emptyBarColorG + Double(lifePoints)/100 * (fullBarColorG - emptyBarColorG)
        let resultColorB = emptyBarColorB + Double(lifePoints)/100 * (fullBarColorB - emptyBarColorB)

        return UIColor(red: resultColorR, green: resultColorG, blue: resultColorB, alpha: 1.0)
    }
}