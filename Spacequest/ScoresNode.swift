import SpriteKit


class ScoresNode: SKLabelNode
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override init()
    {
        value = 0
        
        super.init()

        self.fontSize = 18.0
        self.fontColor = UIColor(white: 1, alpha: 0.7)
        self.fontName = FontName.Wawati.rawValue
        self.horizontalAlignmentMode = .left;

        update()
    }
    
    
    var value: Int = 0
    {
    
    didSet
    {
        update()
    }
    
    }
    
    
    func update()
    {
        self.text = "Score: \(value)"
    }
}
