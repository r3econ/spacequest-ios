import SpriteKit


class Button: SKSpriteNode {
   
    var touchUpInsideAction: ()?
    var touchDownAction: ()?
    var touchUpAction: ()?
    var textureNormal: SKTexture?
    var textureSelected: SKTexture?
    var textureDisabled: SKTexture?
    var titleLabelNode: SKLabelNode?
    
    var title: String? {
    
    set {
        
        if !titleLabelNode {
            
            titleLabelNode = SKLabelNode()
            titleLabelNode!.horizontalAlignmentMode = .Center
            titleLabelNode!.verticalAlignmentMode = .Center
            
            self.addChild(titleLabelNode)
        }
        
        titleLabelNode!.text = title
    }
    
    get {
        return self.title
    }
    }

    var isSelected: Bool {
    
    set {
        
        self.texture = newValue ? textureSelected : textureNormal
    }
    
    get {
        
        return self.isSelected
    }
    }
    
    var isEnabled: Bool {
    
    set {
        
        self.texture = newValue ? textureNormal : textureDisabled
    }
    
    get {
        
        return self.isEnabled
    }
    }

    
    init(textureNormal: SKTexture!, textureSelected: SKTexture!, textureDisabled: SKTexture!) {
        
        self.textureNormal = textureNormal
        self.textureSelected = textureSelected
        self.textureDisabled = textureDisabled
        
        super.init(texture: textureNormal)
        
        isEnabled = true
        isSelected = false
    }
    
    
    convenience init(textureNormal: SKTexture!, textureSelected: SKTexture!) {
        
        self.init(textureNormal:textureNormal, textureSelected:textureSelected, textureDisabled:nil)
    }
    
    
    convenience init(normalImageNamed: String!, selectedImageNamed: String!, disabledImageNamed: String!) {
        
        var textureNormal = SKTexture(imageNamed: normalImageNamed)
        var textureSelected = SKTexture(imageNamed: selectedImageNamed)
        
        self.init(textureNormal:textureNormal, textureSelected:textureSelected, textureDisabled:nil)
    }
    
    
    convenience init(normalImageNamed: String!, selectedImageNamed: String!) {
        
        self.init(normalImageNamed: normalImageNamed, selectedImageNamed: selectedImageNamed, disabledImageNamed: nil)
    }
}


/**
Touches
*/
extension Button {
    
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        if isEnabled {

            if touchDownAction {
                
                touchDownAction!
            }
            
            self.isSelected = true
        }
    }
    
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        if isEnabled {

            var touch : AnyObject! = touches.anyObject()
            var location = touch.locationInNode(self)
            
            self.isSelected = CGRectContainsPoint(frame, location)
        }
    }
    
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
        if isEnabled {

            var touch : AnyObject! = touches.anyObject()
            var location = touch.locationInNode(self)
            
            if CGRectContainsPoint(frame, location) {
            
                if touchUpInsideAction {
                    
                    touchUpInsideAction!
                }
            }
            
            if touchUpAction {
                
                touchUpAction!
            }
            
            self.isSelected = false
        }
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
        if isEnabled {

            self.isSelected = false
        }
    }
}