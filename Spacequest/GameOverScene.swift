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

protocol GameOverSceneDelegate: class {
    func gameOverSceneDidTapRestartButton(_ gameOverScene: GameOverScene)
}

class GameOverScene: SKScene{

    private var restartButton: Button?
    private var buttons: [Button]?
    private var background: SKSpriteNode?
    weak var gameOverSceneDelegate: GameOverSceneDelegate?

    // MARK: - Scene lifecycle
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.configureButtons()
        self.configureBackground()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Track event
        AnalyticsManager.sharedInstance.trackScene("GameOverScene")
    }
    
}

// MARK: - Configuration

extension GameOverScene {
    
    private func configureBackground() {
        self.background = SKSpriteNode(imageNamed: ImageName.MenuBackgroundPhone.rawValue)
        self.background!.size = self.size
        self.background!.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.background!.zPosition = -1000
        self.addChild(self.background!)
    }
    
    private func configureButtons() {
        // Restart button
        self.restartButton = Button(
            normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonRestartNormal.rawValue)
        
        self.restartButton!.touchUpInsideEventHandler = self.restartButtonTouchUpInsideHandler()
        
        self.buttons = [self.restartButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in (self.buttons!).enumerated() {
            
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != self.buttons!.count - 1 ? horizontalPadding : 0.0
        }
        
        // Calculate origin of first button.
        var buttonOriginX = self.frame.width / 2.0 + totalButtonsWidth / 2.0
        
        // Place buttons in the scene.
        for (_, button) in (self.buttons!).enumerated() {
            button.position = CGPoint(
                x: buttonOriginX - button.size.width/2,
                y: button.size.height * 1.1)
            
            self.addChild(button)
            
            buttonOriginX -= button.size.width + horizontalPadding
            
            let rotateAction = SKAction.rotate(byAngle: CGFloat(.pi/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversed()])
            
            button.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        let handler = { () -> () in
            self.gameOverSceneDelegate?.gameOverSceneDidTapRestartButton(self)
            return
        }
        
        return handler
    }
    
}
