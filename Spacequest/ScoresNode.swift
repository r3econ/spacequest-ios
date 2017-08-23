import SpriteKit

class ScoresNode: SKLabelNode {
    
    var value: Int = 0 {
        didSet {
            self.update()
        }
    }
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init() {
        value = 0
        
        super.init()
        
        self.fontSize = 18.0
        self.fontColor = UIColor(white: 1, alpha: 0.7)
        self.fontName = FontName.Wawati.rawValue
        self.horizontalAlignmentMode = .left;
        
        self.update()
    }
    // MARK: - Configuration
    
    func update() {
        self.text = "Score: \(value)"
    }
    
}
