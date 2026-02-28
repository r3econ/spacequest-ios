//
// Copyright (c) Rafał Sroka
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
typealias ContinuousTouchDownEventHandler = () -> Void

class Button: SKSpriteNode {

    var touchUpInsideEventHandler: TouchUpInsideEventHandler?
    var continuousTouchDownEventHandler: ContinuousTouchDownEventHandler?
    var touchDownEventHandler: TouchDownEventHandler?
    var titleLabelNode: SKLabelNode?
    private let textureNormal: SKTexture
    private let textureSelected: SKTexture?
    private let textureDisabled: SKTexture?

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    init(textureNormal: SKTexture,
         textureSelected: SKTexture? = nil,
         textureDisabled: SKTexture? = nil) {
        self.textureNormal = textureNormal
        self.textureSelected = textureSelected
        self.textureDisabled = textureDisabled

        super.init(texture: textureNormal,
                   color: .clear,
                   size: textureNormal.size())

        isUserInteractionEnabled = true
    }

    convenience init(normalImageNamed: String,
                     selectedImageNamed: String? = nil,
                     disabledImageNamed: String? = nil) {
        let textureNormal = SKTexture(imageNamed: normalImageNamed)

        var textureSelected: SKTexture?
        if let selectedImageNamed {
            textureSelected = SKTexture(imageNamed: selectedImageNamed)
        }

        var textureDisabled: SKTexture?
        if let disabledImageNamed {
            textureDisabled = SKTexture(imageNamed: disabledImageNamed)
        }

        self.init(textureNormal: textureNormal,
                  textureSelected: textureSelected,
                  textureDisabled: textureDisabled)
    }

    // MARK: - Properties

    var title: String? {
        get { titleLabelNode?.text }
        set { ensureTitleLabelNode().text = newValue }
    }

    var font: UIFont? {
        get {
            guard let node = titleLabelNode,
                  let fontName = node.fontName,
                  !fontName.isEmpty else { return nil }
            return UIFont(name: fontName, size: node.fontSize)
        }
        set {
            let label = ensureTitleLabelNode()
            label.fontName = newValue?.fontName
            label.fontSize = newValue?.pointSize ?? label.fontSize
        }
    }

    var isSelected: Bool = false {
        didSet { texture = isSelected ? textureSelected : textureNormal }
    }

    var isEnabled: Bool = true {
        didSet { texture = isEnabled ? textureNormal : textureDisabled }
    }

    private func ensureTitleLabelNode() -> SKLabelNode {
        if let existing = titleLabelNode { return existing }
        let label = SKLabelNode()
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        addChild(label)
        titleLabelNode = label
        return label
    }
}

// MARK: - Touches

extension Button {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }

        touchDownEventHandler?()
        isSelected = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        if let touch = touches.first, let parent = parent {
            isSelected = contains(touch.location(in: parent))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, let touch = touches.first, let parent = parent else { return }
        if contains(touch.location(in: parent)) {
            touchUpInsideEventHandler?()
        }
        isSelected = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }

        isSelected = false
    }
}
