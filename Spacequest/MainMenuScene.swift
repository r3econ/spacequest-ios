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

protocol MainMenuSceneDelegate: class {
    
    func mainMenuSceneDidTapResumeButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapRestartButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene: MainMenuScene)
}

class MainMenuScene: SKScene {
    
    private var infoButton: Button?
    private var resumeButton: Button?
    private var restartButton: Button?
    private var buttons: [Button]?
    private var background: SKSpriteNode?
    weak var mainMenuSceneDelegate: MainMenuSceneDelegate?
    
    // MARK: - Scene lifecycle
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        configureButtons()
        configureBackground()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Track event
        AnalyticsManager.sharedInstance.trackScene("MainMenuScene")
    }
    
}

// MARK: - Configuration

extension MainMenuScene{
    
    private func configureBackground() {
        background = SKSpriteNode(imageNamed: ImageName.MenuBackgroundPhone.rawValue)
        background!.size = size
        background!.position = CGPoint(x: size.width/2, y: size.height/2)
        background!.zPosition = -1000
        addChild(background!)
    }
    
    private func configureButtons() {
        // Info button.
        infoButton = Button(
            normalImageNamed: ImageName.MenuButtonInfoNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonInfoNormal.rawValue)
        
        infoButton!.touchUpInsideEventHandler = infoButtonTouchUpInsideHandler()
        
        infoButton!.position = CGPoint(
            x: scene!.size.width - 40.0,
            y: scene!.size.height - 25.0)
        
        addChild(infoButton!)
        
        // Resume button.
        resumeButton = Button(
            normalImageNamed: ImageName.MenuButtonResumeNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonResumeNormal.rawValue)
        
        resumeButton!.touchUpInsideEventHandler = resumeButtonTouchUpInsideHandler()
        
        // Restart button.
        restartButton = Button(
            normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonRestartNormal.rawValue)
        
        restartButton!.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()
        
        buttons = [resumeButton!, restartButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in (buttons!).enumerated() {
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != buttons!.count - 1 ? horizontalPadding : 0.0
        }
        
        // Calculate origin of first button.
        var buttonOriginX = frame.width / 2.0 + totalButtonsWidth / 2.0
        
        // Place buttons in the scene.
        for (_, button) in (buttons!).enumerated() {
            button.position = CGPoint(
                x: buttonOriginX - button.size.width/2,
                y: button.size.height * 1.1)
            
            addChild(button)
            
            buttonOriginX -= button.size.width + horizontalPadding
            
            let rotateAction = SKAction.rotate(byAngle: CGFloat(.pi/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversed()])
            
            button.run(SKAction.repeatForever(sequence))
        }
    }
    
    private func resumeButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.mainMenuSceneDelegate?.mainMenuSceneDidTapResumeButton(strongSelf)
        }
    }
    
    private func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.mainMenuSceneDelegate?.mainMenuSceneDidTapRestartButton(strongSelf)
        }
    }
    
    private func infoButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.mainMenuSceneDelegate?.mainMenuSceneDidTapInfoButton(strongSelf)
        }
    }
    
}
