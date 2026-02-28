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

typealias JoystickTranslationUpdateHandler = (CGPoint) -> Void

class Joystick: SKNode {

    var updateHandler: JoystickTranslationUpdateHandler = { _ in }
    let joystickRadius: CGFloat
    private let stickNode: SKSpriteNode
    private let baseNode: SKSpriteNode
    private var isTouchedDown = false
    private var currentJoystickTranslation = CGPoint.zero
    private var updateTimer: Timer?

    // MARK: - Initialization

    init(maximumRadius: CGFloat,
         stickImageNamed: String,
         baseImageNamed: String,
         joystickUpdateTimeInterval: TimeInterval = 1/40.0) {

        joystickRadius = maximumRadius
        stickNode = SKSpriteNode(imageNamed: stickImageNamed)
        baseNode = SKSpriteNode(imageNamed: baseImageNamed)

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
        baseNode.position = CGPoint.zero
        addChild(baseNode)

        stickNode.position = CGPoint.zero
        addChild(stickNode)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    var size: CGSize {
        CGSize(width: joystickRadius + stickNode.size.width/2,
               height: joystickRadius + stickNode.size.height/2)
    }

    override func removeFromParent() {
        updateTimer?.invalidate()
        updateTimer = nil
        super.removeFromParent()
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        isTouchedDown = true
        updateWithTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        isTouchedDown = true
        updateWithTouch(touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchedDown = false
        reset()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchedDown = false
        reset()
    }

    private func updateWithTouch(_ touch: UITouch) {
        var location = touch.location(in: self)
        let distance = hypot(location.x, location.y)

        if distance >= joystickRadius {
            let normalizedTranslationVector = CGPoint(x: location.x / distance,
                                                      y: location.y / distance)

            location = CGPoint(x: normalizedTranslationVector.x * joystickRadius,
                               y: normalizedTranslationVector.y * joystickRadius)
        }

        // Calculate joystick translation
        currentJoystickTranslation.x = location.x/joystickRadius
        currentJoystickTranslation.y = location.y/joystickRadius

        stickNode.position = location
    }

    @objc private func handleJoystickTranslationUpdate() {
        guard isTouchedDown else { return }
        updateHandler(currentJoystickTranslation)
    }

    private func reset() {
        stickNode.position = CGPoint.zero
    }
}
