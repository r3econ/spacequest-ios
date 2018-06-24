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

typealias TouchUpInsideEventHandler = () -> Void
typealias TouchDownEventHandler = () -> Void
typealias ContinousTouchDownEventHandler = () -> Void

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
        isEnabled = true
        isSelected = false
        
        super.init(texture: textureNormal,
            color: UIColor.brown,
            size: textureNormal.size())
        
        isUserInteractionEnabled = true
    }
    
    convenience init(textureNormal: SKTexture, textureSelected: SKTexture!) {
        self.init(textureNormal:textureNormal,
                  textureSelected:textureSelected,
                  textureDisabled:nil)
    }
    
    convenience init(normalImageNamed: String, selectedImageNamed: String!, disabledImageNamed: String!) {
        let textureNormal = SKTexture(imageNamed: normalImageNamed)
        let textureSelected = SKTexture(imageNamed: selectedImageNamed)
        
        self.init(textureNormal:textureNormal,
                  textureSelected:textureSelected,
                  textureDisabled:nil)
    }
    
    convenience init(normalImageNamed: String, selectedImageNamed: String!) {
        self.init(normalImageNamed: normalImageNamed,
                  selectedImageNamed: selectedImageNamed,
                  disabledImageNamed: nil)
    }
    
    // MARK: - Properties

    var title: String? {
        set {
            if titleLabelNode == nil {
                titleLabelNode = SKLabelNode()
                titleLabelNode!.horizontalAlignmentMode = .center
                titleLabelNode!.verticalAlignmentMode = .center
                
                addChild(titleLabelNode!)
            }
            
            titleLabelNode!.text = newValue!
        }
        get {
            if titleLabelNode != nil {
                return titleLabelNode!.text
            }
            
            return nil
        }
    }
    
    var font: UIFont? {
        set {
            if titleLabelNode == nil {
                titleLabelNode = SKLabelNode()
                titleLabelNode!.horizontalAlignmentMode = .center
                titleLabelNode!.verticalAlignmentMode = .center
                
                addChild(titleLabelNode!)
            }
            
            titleLabelNode!.fontName = newValue!.fontName
            titleLabelNode!.fontSize = newValue!.pointSize
        }
        get {
            if titleLabelNode != nil {
                return UIFont(name: titleLabelNode!.fontName!, size: titleLabelNode!.fontSize)
            }
            
            return nil
        }
    }
    
    var selected: Bool {
        set {
            isSelected = newValue
            texture = newValue ? textureSelected : textureNormal
        }
        get {
            return isSelected
        }
    }
    
    var enabled: Bool {
        set {
            isEnabled = newValue
            texture = newValue ? textureNormal : textureDisabled
        }
        get {
            return isEnabled
        }
    }
    
}

// MARK: - Touches

extension Button {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            if touchDownEventHandler != nil {
                touchDownEventHandler!()
            }
            
            selected = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            let touch : AnyObject! = touches.first
            let location = touch.location(in: self)
            
            selected = frame.contains(location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            if touchUpInsideEventHandler != nil {
                touchUpInsideEventHandler!()
            }
            
            selected = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            selected = false
        }
    }
    
}
