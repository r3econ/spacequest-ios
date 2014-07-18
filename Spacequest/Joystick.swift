import SpriteKit


class Joystick: SKNode
{
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    
    
    var joystickRadius: CGFloat
    var stickNode: SKSpriteNode
    var baseNode: SKSpriteNode?
    
    init(maximumRadius: CGFloat, stickImageNamed: String, baseImageNamed: String?)
    {
        joystickRadius = maximumRadius
        stickNode = SKSpriteNode(imageNamed: stickImageNamed);
        
        if baseImageNamed
        {
            baseNode = SKSpriteNode(imageNamed: baseImageNamed!)
        }
        
        super.init()
        
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
        
        UIView.animateWithDuration(0.2,
            animations:
            {
                // your code.
            },
            completion:
            {
                (completed: Bool) in
                // your code.
            })
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        reset()
    }
    
    
    func updateWithTouch(touch: UITouch)
    {
        var location = touch.locationInNode(self)
        
        var distance = pow(CDouble(location.x - position.x), 2) + pow(CDouble(location.y - position.y), 2)
        
        if distance > CDouble(joystickRadius)
        {
            var angle = atan2f(CFloat(location.y - position.y), CFloat(location.x - position.x))
            
            location.x = position.x + joystickRadius * CGFloat(cosf(angle))
            location.y = position.y + joystickRadius * CGFloat(sinf(angle))
        }
        
        stickNode.position = location
        
        x = (location.x - position.x) / joystickRadius
        y = (location.y - position.y) / joystickRadius
    }
    
    
    func reset()
    {
        stickNode.position = CGPointZero
        
        x = 0.0
        y = 0.0
    }
}