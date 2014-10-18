import SpriteKit


typealias TouchUpInsideEventHandler = () -> ()
typealias TouchDownEventHandler = () -> ()
typealias ContinousTouchDownEventHandler = () -> ()


class Button: SKSpriteNode
{
    var touchUpInsideEventHandler: TouchUpInsideEventHandler?
    var continousTouchDownEventHandler: ContinousTouchDownEventHandler?
    var touchDownEventHandler: TouchDownEventHandler?
    var textureNormal: SKTexture?
    var textureSelected: SKTexture?
    var textureDisabled: SKTexture?
    var titleLabelNode: SKLabelNode?
    var isSelected: Bool = false
    var isEnabled: Bool = true
    
    
    // Initializers.
    required init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    
    init(textureNormal: SKTexture!, textureSelected: SKTexture!, textureDisabled: SKTexture!)
    {
        self.textureNormal = textureNormal
        self.textureSelected = textureSelected
        self.textureDisabled = textureDisabled
        self.isEnabled = true
        self.isSelected = false
        
        super.init(texture: textureNormal, color: nil, size: textureNormal.size())
        

        self.userInteractionEnabled = true
    }
    
    
    convenience init(textureNormal: SKTexture, textureSelected: SKTexture!)
    {
        self.init(textureNormal:textureNormal, textureSelected:textureSelected, textureDisabled:nil)
    }
    
    
    convenience init(normalImageNamed: String, selectedImageNamed: String!, disabledImageNamed: String!)
    {
        var textureNormal = SKTexture(imageNamed: normalImageNamed)
        var textureSelected = SKTexture(imageNamed: selectedImageNamed)
        
        self.init(textureNormal:textureNormal, textureSelected:textureSelected, textureDisabled:nil)
    }
    
    
    convenience init(normalImageNamed: String, selectedImageNamed: String!)
    {
        self.init(normalImageNamed: normalImageNamed, selectedImageNamed: selectedImageNamed, disabledImageNamed: nil)
    }
    

    // Computed properties.
    var title: String?
    {
    set
    {
        if titleLabelNode == nil
        {
            titleLabelNode = SKLabelNode()
            titleLabelNode!.horizontalAlignmentMode = .Center
            titleLabelNode!.verticalAlignmentMode = .Center
            
            self.addChild(titleLabelNode)
        }
        
        titleLabelNode!.text = newValue
    }
    
    get
    {
        if titleLabelNode != nil
        {
            return titleLabelNode!.text
        }
        
        return nil
    }
    }
    
    
    var font: UIFont?
    {
    set
    {
        if titleLabelNode == nil
        {
            titleLabelNode = SKLabelNode()
            titleLabelNode!.horizontalAlignmentMode = .Center
            titleLabelNode!.verticalAlignmentMode = .Center
            
            self.addChild(titleLabelNode)
        }
        
        titleLabelNode!.fontName = newValue!.fontName
        titleLabelNode!.fontSize = newValue!.pointSize
    }
    
    get
    {
        if titleLabelNode != nil
        {
            return UIFont(name: titleLabelNode!.fontName, size: titleLabelNode!.fontSize)
        }
        
        return nil
    }
    }
    
    var selected: Bool
    {
    
    set
    {
        self.isSelected = newValue
        self.texture = newValue ? textureSelected : textureNormal
    }
    
    get
    {
        return self.isSelected
    }
    }
    
    var enabled: Bool
    
    {
    
    set
    {
        self.isEnabled = newValue
        self.texture = newValue ? textureNormal : textureDisabled
    }
    
    get
    {
        return self.isEnabled
    }
    
    }
}


/**
Touches
*/
extension Button
{
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!)
    {
        if self.isEnabled
        {
            if touchDownEventHandler != nil
            {
                touchDownEventHandler!()
            }
            
            self.selected = true
        }
    }
    
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        if isEnabled
        {
            var touch : AnyObject! = touches.anyObject()
            var location = touch.locationInNode(self)
            
            self.selected = CGRectContainsPoint(frame, location)
        }
    }
    
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)
    {
        if isEnabled
        {
            if touchUpInsideEventHandler != nil
            {
                touchUpInsideEventHandler!()
            }
            
            self.selected = false
        }
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        if isEnabled
        {
            self.selected = false
        }
    }
}