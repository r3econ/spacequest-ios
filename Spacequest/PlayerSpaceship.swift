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

import CoreGraphics
import SpriteKit

class PlayerSpaceship: Spaceship {

    private let engineBurstEmitter: SKEmitterNode

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        guard let emitter = SKEmitterNode(fileNamed: "PlayerSpaceshipEngineBurst") else {
            preconditionFailure("Failed to load PlayerSpaceshipEngineBurst.sks")
        }
        self.engineBurstEmitter = emitter
        super.init(coder: aDecoder)
        configureCollisions()
        configureEngineBurst()
    }

    required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        guard let emitter = SKEmitterNode(fileNamed: "PlayerSpaceshipEngineBurst") else {
            preconditionFailure("Failed to load PlayerSpaceshipEngineBurst.sks")
        }
        self.engineBurstEmitter = emitter
        super.init(texture: texture, color: color, size: size)
        configureCollisions()
        configureEngineBurst()
    }

    convenience init() {
        let size = CGSize(width: 64, height: 50)
        self.init(texture: SKTexture(imageNamed: ImageName.PlayerSpaceship.rawValue),
                  color: UIColor.brown,
                  size: size)
        name = NSStringFromClass(PlayerSpaceship.self)
    }

    // MARK: - Configuration

    private func configureCollisions() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.allowsRotation = false

        physicsBody!.categoryBitMask = CategoryBitmask.playerSpaceship.rawValue
        physicsBody!.collisionBitMask =
            CategoryBitmask.enemyMissile.rawValue |
            CategoryBitmask.screenBounds.rawValue

        physicsBody!.contactTestBitMask =
            CategoryBitmask.enemySpaceship.rawValue |
            CategoryBitmask.enemyMissile.rawValue
    }

    private func configureEngineBurst() {
        engineBurstEmitter.position = CGPoint(x: -size.width/2 - 5.0, y: 0.0)
        addChild(engineBurstEmitter)
    }

    // MARK: - Special actions

    func launchMissile() {
        guard let scene = self.scene else { return }

        // Create a missile
        let missile = Missile.playerMissile()
        missile.position = CGPoint(x: frame.maxX + 10.0, y: position.y)
        missile.zPosition = zPosition - 1

        // Place it in the scene
        scene.addChild(missile)

        // Make it move
        let velocity: CGFloat = 600.0
        let moveDuration = scene.size.width / velocity
        let missileEndPosition = CGPoint(x: position.x + scene.size.width, y: position.y)

        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveAction, removeAction]))

        // Play sound
        scene.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
}
