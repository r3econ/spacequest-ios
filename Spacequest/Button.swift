import SpriteKit

typealias TouchUpInsideEventHandler = () -> ()
typealias TouchDownEventHandler = () -> ()
typealias ContinousTouchDownEventHandler = () -> ()

class Button: SKSpriteNode {
    
    var touchUpInsideEventHandler: TouchUpInsideEventHandler?
    var continousTouchDownEventHandler: ContinousTouchDownEventHandler?
    var touchDownEventHandler: TouchDownEventHandler?
    var textureNormal: SKTexture?
    var textureSelected: SKTexture?
    var textureDisabled: SKTexture?
    var titleLabelNode: SKLabelNode?
    var isSelected: Bool = false
    var isEnabled: Bool = true
    
    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(textureNormal: SKTexture!, textureSelected: SKTexture!, textureDisabled: SKTexture!) {
        self.textureNormal = textureNormal
        self.textureSelected = textureSelected
        self.textureDisabled = textureDisabled
        self.isEnabled = true
        self.isSelected = false
        
        super.init(texture: textureNormal,
            color: UIColor.brown,
            size: textureNormal.size())
        
        self.isUserInteractionEnabled = true
    }
    
    convenience init(textureNormal: SKTexture, textureSelected: SKTexture!) {
        self.init(textureNormal:textureNormal, textureSelected:textureSelected, textureDisabled:nil)
    }
    
    convenience init(normalImageNamed: String, selectedImageNamed: String!, disabledImageNamed: String!) {
        let textureNormal = SKTexture(imageNamed: normalImageNamed)
        let textureSelected = SKTexture(imageNamed: selectedImageNamed)
        
        self.init(textureNormal:textureNormal, textureSelected:textureSelected, textureDisabled:nil)
    }
    
    convenience init(normalImageNamed: String, selectedImageNamed: String!) {
        self.init(normalImageNamed: normalImageNamed, selectedImageNamed: selectedImageNamed, disabledImageNamed: nil)
    }
    
    // MARK: - Properties

    var title: String? {
        set {
            if self.titleLabelNode == nil {
                self.titleLabelNode = SKLabelNode()
                self.titleLabelNode!.horizontalAlignmentMode = .center
                self.titleLabelNode!.verticalAlignmentMode = .center
                
                self.addChild(self.titleLabelNode!)
            }
            
            self.titleLabelNode!.text = newValue!
        }
        get {
            if self.titleLabelNode != nil {
                return self.titleLabelNode!.text
            }
            
            return nil
        }
    }
    
    var font: UIFont? {
        set {
            if self.titleLabelNode == nil {
                self.titleLabelNode = SKLabelNode()
                self.titleLabelNode!.horizontalAlignmentMode = .center
                self.titleLabelNode!.verticalAlignmentMode = .center
                
                self.addChild(titleLabelNode!)
            }
            
            self.titleLabelNode!.fontName = newValue!.fontName
            self.titleLabelNode!.fontSize = newValue!.pointSize
        }
        get {
            if self.titleLabelNode != nil {
                return UIFont(name: self.titleLabelNode!.fontName!, size: self.titleLabelNode!.fontSize)
            }
            
            return nil
        }
    }
    
    var selected: Bool {
        set {
            self.isSelected = newValue
            self.texture = newValue ? self.textureSelected : self.textureNormal
        }
        get {
            return self.isSelected
        }
    }
    
    var enabled: Bool {
        set {
            self.isEnabled = newValue
            self.texture = newValue ? self.textureNormal : self.textureDisabled
        }
        get {
            return self.isEnabled
        }
    }
    
}

// MARK: - Touches

extension Button {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isEnabled {
            if self.touchDownEventHandler != nil {
                self.touchDownEventHandler!()
            }
            
            self.selected = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isEnabled {
            let touch : AnyObject! = touches.first
            let location = touch.location(in: self)
            
            self.selected = frame.contains(location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isEnabled {
            if self.touchUpInsideEventHandler != nil {
                self.touchUpInsideEventHandler!()
            }
            
            self.selected = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isEnabled {
            self.selected = false
        }
    }
    
}
