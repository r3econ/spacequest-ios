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

protocol MainMenuSceneDelegate: AnyObject {

    func mainMenuSceneDidTapResumeButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapRestartButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene: MainMenuScene)
}

class MainMenuScene: MenuScene {

    weak var mainMenuSceneDelegate: MainMenuSceneDelegate?

    // MARK: - Scene lifecycle

    override func sceneDidLoad() {
        super.sceneDidLoad()

        configureButtons()
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        AnalyticsManager.sharedInstance.trackScene("MainMenuScene")
    }

    // MARK: - Configuration

    private func configureButtons() {
        let infoButton = Button(normalImageNamed: ImageName.MenuButtonInfoNormal.rawValue,
                                selectedImageNamed: ImageName.MenuButtonInfoSelected.rawValue)
        infoButton.touchUpInsideEventHandler = infoButtonTouchUpInsideHandler()
        infoButton.position = CGPoint(x: size.width - 40.0,
                                      y: size.height - 25.0)
        addChild(infoButton)

        let resumeButton = Button(normalImageNamed: ImageName.MenuButtonResumeNormal.rawValue,
                                  selectedImageNamed: ImageName.MenuButtonResumeSelected.rawValue)
        resumeButton.touchUpInsideEventHandler = resumeButtonTouchUpInsideHandler()

        let restartButton = Button(normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
                                   selectedImageNamed: ImageName.MenuButtonRestartSelected.rawValue)
        restartButton.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()

        let buttons = [resumeButton, restartButton]
        var totalButtonsWidth: CGFloat = 0.0

        // Calculate total width of the buttons area.
        for (index, button) in buttons.enumerated() {
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != buttons.count - 1 ? .horizontalPadding : 0.0
        }

        var buttonOriginX = frame.width / 2.0 + totalButtonsWidth / 2.0

        // Place buttons in the scene.
        for button in buttons {
            button.position = CGPoint(x: buttonOriginX - button.size.width/2,
                                      y: button.size.height * 1.1)
            addChild(button)

            buttonOriginX -= button.size.width + .horizontalPadding

            let rotateAction = SKAction.rotate(byAngle: CGFloat(.pi/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversed()])
            button.run(SKAction.repeatForever(sequence))
        }
    }

    private func resumeButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let self else { return }
            self.mainMenuSceneDelegate?.mainMenuSceneDidTapResumeButton(self)
        }
    }

    private func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let self else { return }

            self.mainMenuSceneDelegate?.mainMenuSceneDidTapRestartButton(self)
        }
    }

    private func infoButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { [weak self] in
            guard let self else { return }

            self.mainMenuSceneDelegate?.mainMenuSceneDidTapInfoButton(self)
        }
    }
}

private extension CGFloat {
    static let horizontalPadding: CGFloat = 20.0
}
