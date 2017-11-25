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
        self.configureCollisions()
    }
    
    deinit {
        self.missileLaunchTimer?.invalidate()
    }
    
    // MARK: - Configuration

    fileprivate func configureCollisions() {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.categoryBitMask = CategoryBitmask.enemySpaceship.rawValue
        self.physicsBody!.collisionBitMask =
            CategoryBitmask.enemySpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue |
            CategoryBitmask.playerSpaceship.rawValue
        
        self.physicsBody!.contactTestBitMask =
            CategoryBitmask.playerSpaceship.rawValue |
            CategoryBitmask.playerMissile.rawValue
    }
    
    // MARK: - Special actions
    
    func scheduleRandomMissileLaunch() {
        self.missileLaunchTimer?.invalidate()
        
        // Schedule missile launch with random delay
        let backoffTime = TimeInterval((arc4random() % 3) + 1)
        self.missileLaunchTimer = Timer(timeInterval: backoffTime, target: self, selector: #selector(EnemySpaceship.launchMissile), userInfo: nil, repeats: false)
    }
    
    @objc func launchMissile() {
        // Create a missile
        let missile = Missile.enemyMissile()
        missile.position = self.position
        missile.zPosition = self.zPosition - 1
        
        // Place it in the scene
        self.scene!.addChild(missile)
        
        // Make it move
        let velocity: CGFloat = 600.0
        let moveDuration = self.scene!.size.width / velocity
        let missileEndPosition = CGPoint(x: -0.1 * self.scene!.size.width, y: self.position.y)
        
        let moveAction = SKAction.move(to: missileEndPosition, duration: TimeInterval(moveDuration))
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveAction, removeAction]))
        
        // Play sound
        self.scene!.run(SKAction.playSoundFileNamed(SoundName.MissileLaunch.rawValue, waitForCompletion: false))
    }
    
}
