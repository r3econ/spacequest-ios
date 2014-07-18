import SpriteKit


typealias JoystickTranslationUpdateHandler = (CGPoint) -> ()


class Joystick: SKSpriteNode
{
    var updateBlock: JoystickTranslationUpdateHandler?
    var joystickRadius: CGFloat
    var stickNode: SKSpriteNode
    
    init(maximumRadius: CGFloat, stickImageNamed: String, baseImageNamed: String)
    {
        joystickRadius = maximumRadius
        stickNode = SKSpriteNode(imageNamed: stickImageNamed);
        let baseTexture  = SKTexture(imageNamed: baseImageNamed)
        
        super.init(texture: baseTexture,
            color: UIColor.whiteColor(),
            size: baseTexture.size())
        
        // Configure and add stick node.
        stickNode.position = CGPointZero
        self.addChild(stickNode);
        
        userInteractionEnabled = true
    }
}


/**
 Touches
*/
extension Joystick
{
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!)
    {
        var touch : AnyObject! = touches.anyObject()
        
        if touch
        {
            updateWithTouch(touch as UITouch)
        }
    }
    
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        var touch : AnyObject! = touches.anyObject()
        
        if touch
        {
            updateWithTouch(touch as UITouch)
        }
    }
    
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)
    {
        reset()
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        reset()
    }
    
    
    func updateWithTouch(touch: UITouch)
    {
        var location = touch.locationInNode(self)
        let distance = CGFloat(sqrt(pow(CDouble(location.x), 2) + pow(CDouble(location.y), 2)))
        
        if distance < joystickRadius
        {
            if updateBlock
            {
                let angle = atan2f(CFloat(location.y), CFloat(location.x))
                let translation = CGPoint(x: joystickRadius * CGFloat(cosf(angle)), y: joystickRadius * CGFloat(sinf(angle)))
                
                updateBlock!(translation)
            }
        }
        else
        {
            var normalizedTranslationVector = CGPoint(x: location.x / distance, y: location.y / distance)
            
            location = CGPoint(x: normalizedTranslationVector.x * joystickRadius,
                y: normalizedTranslationVector.y * joystickRadius)
        }
        
        stickNode.position = location
    }
    
    
    func reset()
    {
        stickNode.position = CGPointZero
    }
}