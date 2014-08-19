import SpriteKit


typealias JoystickTranslationUpdateHandler = (CGPoint) -> ()
let kDefaultJoystickUpdateTimeInterval: NSTimeInterval = 1/40.0


class Joystick: SKNode
{
    var updateHandler: JoystickTranslationUpdateHandler?
    var joystickRadius: CGFloat = 0.0
    var stickNode: SKSpriteNode?
    var baseNode: SKSpriteNode?
    var isTouchedDown: Bool = false
    var currentJoystickTranslation: CGPoint = CGPointZero
    var updateTimer: NSTimer?
    
    
    required init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    
    init(maximumRadius: CGFloat, stickImageNamed: String, baseImageNamed: String?)
    {
        currentJoystickTranslation = CGPointZero
        isTouchedDown = false
        joystickRadius = maximumRadius
        stickNode = SKSpriteNode(imageNamed: stickImageNamed);
        
        if baseImageNamed != nil
        {
            baseNode = SKSpriteNode(imageNamed: baseImageNamed);
        }
        
        super.init()
        
        // Create a timer that will call method that will notify about
        // Joystick movements.
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(
            kDefaultJoystickUpdateTimeInterval,
            target: self,
            selector: Selector("handleJoystickTranslationUpdate"),
            userInfo: nil,
            repeats: true)
        
        // Configure and add stick & base nodes.
        if baseNode != nil
        {
            baseNode!.position = CGPointZero
            self.addChild(baseNode);
        }
        
        stickNode!.position = CGPointZero
        self.addChild(stickNode);
        
        userInteractionEnabled = true
    }
    
    
    var size: CGSize
    {
    get
    {
        return CGSize(
            width: joystickRadius + stickNode!.size.width/2,
            height: joystickRadius + stickNode!.size.height/2)
    }
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
            isTouchedDown = true
            updateWithTouch(touch as UITouch)
        }
    }
    
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        var touch : AnyObject! = touches.anyObject()
        
        if touch
        {
            isTouchedDown = true
            updateWithTouch(touch as UITouch)
        }
    }
    
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)
    {
        isTouchedDown = false
        reset()
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        isTouchedDown = false
        reset()
    }
    
    
    func updateWithTouch(touch: UITouch)
    {
        var location = touch.locationInNode(self)
        let distance = CGFloat(sqrt(pow(CDouble(location.x), 2) + pow(CDouble(location.y), 2)))
        
        if distance >= joystickRadius
        {
            var normalizedTranslationVector = CGPoint(x: location.x / distance, y: location.y / distance)
            
            location = CGPoint(x: normalizedTranslationVector.x * joystickRadius,
                y: normalizedTranslationVector.y * joystickRadius)
        }
        
        // Calculate joystick translation.
        currentJoystickTranslation.x = location.x/joystickRadius
        currentJoystickTranslation.y = location.y/joystickRadius
        
        stickNode!.position = location
    }
    
    
    func handleJoystickTranslationUpdate()
    {
        if isTouchedDown && updateHandler != nil
        {
            updateHandler!(currentJoystickTranslation)
        }
    }
    
    
    func reset()
    {
        stickNode!.position = CGPointZero
    }
}