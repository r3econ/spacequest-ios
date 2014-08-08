import SpriteKit


class LifeIndicator: SKSpriteNode
{
    var titleLabelNode: SKLabelNode?

    init(texture: SKTexture!)
    {
        value = 100
        
        super.init(texture: texture,
            color: nil,
            size: texture.size())
        
        titleLabelNode = SKLabelNode(fontNamed: FontName.Wawati.toRaw())
        titleLabelNode!.fontSize = 14.0
        titleLabelNode!.fontColor = UIColor(white: 1.0, alpha: 0.7)
        titleLabelNode!.horizontalAlignmentMode = .Center
        titleLabelNode!.verticalAlignmentMode = .Center

        update()
        
        self.addChild(titleLabelNode)
    }
    
    var value: Int
    {
    
    didSet
    {
        update()
    }
    
    }
    
    
    func update()
    {
        titleLabelNode!.text = "\(value)"
        
        let blendColor = lifeBallColor()
        let blendFactor = 0.9
        
        self.color = blendColor
        self.colorBlendFactor = blendFactor
        titleLabelNode!.color = blendColor
        titleLabelNode!.colorBlendFactor = blendFactor
    }
    
    
    func lifeBallColor() -> UIColor
    {
        var fullBarColorR = 0.0, fullBarColorG = 0.0, fullBarColorB = 0.0, fullBarColorAlpha  = 0.0
        var emptyBarColorR = 0.0, emptyBarColorG = 0.0, emptyBarColorB = 0.0, emptyBarColorAlpha = 0.0
        
        UIColor.greenColor().getRed(&fullBarColorR, green: &fullBarColorG, blue: &fullBarColorB, alpha: &fullBarColorAlpha)
        UIColor.redColor().getRed(&emptyBarColorR, green: &emptyBarColorG, blue: &emptyBarColorB, alpha: &emptyBarColorAlpha)

        let resultColorR = emptyBarColorR + Double(value)/100 * (fullBarColorR - emptyBarColorR)
        let resultColorG = emptyBarColorG + Double(value)/100 * (fullBarColorG - emptyBarColorG)
        let resultColorB = emptyBarColorB + Double(value)/100 * (fullBarColorB - emptyBarColorB)

        return UIColor(red: resultColorR, green: resultColorG, blue: resultColorB, alpha: 1.0)
    }
}