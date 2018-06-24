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

class EnemySpaceship: Spaceship {
    
    fileprivate var missileLaunchTimer: Timer?
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    init(lifePoints: Int) {
        let size = CGSize(width: 36, height: 31)
        super.init(texture: SKTexture(imageNamed: ImageName.EnemySpaceship.rawValue), color: UIColor.brown, size: size)
        
        self.lifePoints = lifePoints
        configureCollisions()
    }
    
    deinit {
        missileLaunchTimer?.invalidate()
    }
    
    // MARK: - Configuration

    fileprivate func configureCollisions() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.categoryBitMask = CategoryBitmask.enemySpaceship.rawValue
        physicsBody!.collisionBitMask =
            CategoryBitmask.enemySpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue |
            CategoryBitmask.playerSpaceship.rawValue
        
        physicsBody!.contactTestBitMask =
            CategoryBitmask.playerSpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue
    }
    
    // MARK: - Special actions
    
    func scheduleRandomMissileLaunch() {
        missileLaunchTimer?.invalidate()
        
        // Schedule missile launch with random delay
        let backoffTime = TimeInterval((arc4random() % 3) + 1)
        missileLaunchTimer = Timer(timeInterval: backoffTime, target: self, selector: #selector(EnemySpaceship.launchMissile), userInfo: nil, repeats: false)
    }
    
    @objc func launchMissile() {
        // Create a missile
        let missile = Missile.enemyMissile()
        missile.position = position
        missile.zPosition = zPosition - 1
        
        // Place it in the scene
        scene!.addChild(missile)
        
        // Make it move
        let velocity: CGFloat = 600.0
        let moveDuration = scene!.size.width / velocity
        let missileEndPosition = CGPoint(x: -0.1 * scene!.size.width, y: position.y)
        
        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveAction, removeAction]))
        
        // Play sound
        scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
    
}
