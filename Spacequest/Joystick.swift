//
// Copyright (c) 2016 Rafał Sroka
//
// Licensed under the GNU General Public License, Version 3.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
//   https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SpriteKit

typealias JoystickTranslationUpdateHandler = (CGPoint) -> Void

class Joystick: SKNode {
    
    let joystickUpdateTimeInterval: TimeInterval! = 1/40.0
    var updateHandler: JoystickTranslationUpdateHandler?
    var joystickRadius: CGFloat = 0.0
    var stickNode: SKSpriteNode?
    var baseNode: SKSpriteNode?
    var isTouchedDown: Bool = false
    var currentJoystickTranslation: CGPoint = CGPoint.zero
    var updateTimer: Timer?
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(maximumRadius: CGFloat,
         stickImageNamed: String,
         baseImageNamed: String?,
         joystickUpdateTimeInterval: TimeInterval = 1/40.0) {
        
        currentJoystickTranslation = CGPoint.zero
        isTouchedDown = false
        joystickRadius = maximumRadius
        stickNode = SKSpriteNode(imageNamed: stickImageNamed);
        
        if baseImageNamed != nil {
            baseNode = SKSpriteNode(imageNamed: baseImageNamed!);
        }
        
        super.init()
        
        // Create a timer that will call method that will notify about
        // Joystick movements.
        updateTimer = Timer.scheduledTimer(
            timeInterval: joystickUpdateTimeInterval,
            target: self,
            selector: #selector(Joystick.handleJoystickTranslationUpdate),
            userInfo: nil,
            repeats: true)
        
        // Configure and add stick & base nodes.
        if baseNode != nil {
            baseNode!.position = CGPoint.zero
            addChild(baseNode!);
        }
        
        stickNode!.position = CGPoint.zero
        addChild(stickNode!);
        
        isUserInteractionEnabled = true
    }
    
    var size: CGSize {
        get {
            return CGSize(width: joystickRadius + stickNode!.size.width/2,
                          height: joystickRadius + stickNode!.size.height/2)
        }
    }
    
}

// MARK: - Touches

extension Joystick {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch : AnyObject! = touches.first
        
        if (touch != nil) {
            isTouchedDown = true
            updateWithTouch(touch as! UITouch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch : AnyObject! = touches.first
        
        if (touch != nil) {
            isTouchedDown = true
            updateWithTouch(touch as! UITouch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchedDown = false
        reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchedDown = false
        reset()
    }
    
    func updateWithTouch(_ touch: UITouch) {
        var location = touch.location(in: self)
        let distance = CGFloat(sqrt(pow(CDouble(location.x), 2) + pow(CDouble(location.y), 2)))
        
        if distance >= joystickRadius {
            let normalizedTranslationVector = CGPoint(x: location.x / distance, y: location.y / distance)
            
            location = CGPoint(x: normalizedTranslationVector.x * joystickRadius,
                               y: normalizedTranslationVector.y * joystickRadius)
        }
        
        // Calculate joystick translation.
        currentJoystickTranslation.x = location.x/joystickRadius
        currentJoystickTranslation.y = location.y/joystickRadius
        
        stickNode!.position = location
    }
    
    @objc func handleJoystickTranslationUpdate() {
        if isTouchedDown && updateHandler != nil {
            updateHandler!(currentJoystickTranslation)
        }
    }
    
    func reset() {
        stickNode!.position = CGPoint.zero
    }
    
}
