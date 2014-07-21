import SpriteKit


typealias TouchUpInsideEventHandler = () -> ()
typealias TouchDownEventHandler = () -> ()
typealias ContinousTouchDownEventHandler = () -> ()


class Button: SKSpriteNode
{
    var touchUpInsideEventHandler: TouchUpInsideEventHandler?
    var continousTouchDownEventHandler: ContinousTouchDownEventHandler?
    var touchDownEventHandler: TouchDownEventHandler?
    var textureNormal: SKTexture
    var textureSelected: SKTexture?
    var textureDisabled: SKTexture?
    var titleLabelNode: SKLabelNode?
    var isSelected: Bool
    var isEnabled: Bool
    
    
    // Initializers.
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
        if !titleLabelNode
        {
            titleLabelNode = SKLabelNode()
            titleLabelNode!.horizontalAlignmentMode = .Center
            titleLabelNode!.verticalAlignmentMode = .Center
            
            self.addChild(titleLabelNode)
        }
        
        titleLabelNode!.text = title
    }
    
    get
    {
        return self.title
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
            if touchDownEventHandler
            {
                touchDownEventHandler!()
            }
            
            self.isSelected = true
        }
    }
    
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        if isEnabled
        {
            var touch : AnyObject! = touches.anyObject()
            var location = touch.locationInNode(self)
            
            self.isSelected = CGRectContainsPoint(frame, location)
        }
    }
    
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)
    {
        if isEnabled
        {
            var touch : AnyObject! = touches.anyObject()
            var location = touch.locationInNode(self)
            
            if CGRectContainsPoint(frame, location)
            {
                if touchUpInsideEventHandler
                {
                    touchUpInsideEventHandler!()
                }
            }
            
            self.isSelected = false
        }
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        if isEnabled
        {
            self.isSelected = false
        }
    }
}