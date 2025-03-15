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

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var gameScene: GameScene?

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        startNewGame(animated: false)

        // Start the background music
        MusicManager.shared.playBackgroundMusic()
    }

    // MARK: - Appearance

    override var shouldAutorotate: Bool {
        return true
    }

    // Make sure only the landscape mode is supported
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var prefersStatusBarHidden: Bool {
        // Hide the status bar
        return true
    }

    // MARK: - Configuration

    private func configureView() {
        guard let skView = view as? SKView else {
            preconditionFailure()
        }

        skView.ignoresSiblingOrder = true

        // Enable debugging
#if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
#endif
    }

    // MARK: - Scene handling

    private func startNewGame(animated: Bool = false) {
        // Recreate game scene
        gameScene = GameScene(size: view.frame.size)
        gameScene!.scaleMode = .aspectFill
        gameScene!.gameSceneDelegate = self

        show(gameScene!, animated: animated)
    }

    private func resumeGame(animated: Bool = false,
                            completion:(()->())? = nil) {
        guard let skView = view as? SKView else {
            preconditionFailure()
        }

        if animated {
            // Show game scene
            skView.presentScene(gameScene!,
                                transition: SKTransition.crossFade(withDuration: .sceneTransitionDuration))

            // Remove the menu scene and unpause the game scene after it was shown
            let delay = .sceneTransitionDuration * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + delay / Double(NSEC_PER_SEC)

            DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] in
                self?.gameScene!.isPaused = false

                completion?()
            })
        }
        else {
            // Remove the menu scene and unpause the game scene after it was shown
            skView.presentScene(gameScene!)
            gameScene!.isPaused = false

            completion?()
        }
    }

    private func showMainMenuScene(animated: Bool) {
        let scene = MainMenuScene(size: view.frame.size)
        scene.mainMenuSceneDelegate = self

        // Pause the game and show main menu
        gameScene!.isPaused = true
        show(scene, animated: animated)
    }

    private func showGameOverScene(animated: Bool) {
        // Create game over scene
        let scene = GameOverScene(size: view.frame.size)
        scene.gameOverSceneDelegate = self

        // Pause the game and show game over
        gameScene!.isPaused = true
        show(scene, animated: animated)
    }

    private func show(_ scene: SKScene,
                      scaleMode: SKSceneScaleMode = .aspectFill,
                      animated: Bool = true) {
        guard let skView = view as? SKView else {
            preconditionFailure()
        }

        scene.scaleMode = .aspectFill

        if animated {
            skView.presentScene(scene,
                                transition: SKTransition.crossFade(withDuration: .sceneTransitionDuration))
        } else {
            skView.presentScene(scene)
        }
    }

}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {

    func didTapMainMenuButton(in gameScene: GameScene) {
        // Show initial, main menu scene
        showMainMenuScene(animated: true)
    }

    func playerDidLose(withScore score: Int, in gameScene:GameScene) {
        // Player lost, show game over scene
        showGameOverScene(animated: true)
    }

}

// MARK: - MainMenuSceneDelegate

extension GameViewController: MainMenuSceneDelegate {

    func mainMenuSceneDidTapResumeButton(_ mainMenuScene: MainMenuScene) {
        resumeGame(animated: true) {
            // Remove main menu scene when game is resumed
            mainMenuScene.removeFromParent()
        }
    }

    func mainMenuSceneDidTapRestartButton(_ mainMenuScene: MainMenuScene) {
        startNewGame(animated: true)
    }

    func mainMenuSceneDidTapInfoButton(_ mainMenuScene:MainMenuScene) {
        // Create a simple alert with copyright information
        let alertController = UIAlertController(title: "About",
                                                message: "Copyright 2016 Rafał Sroka. All rights reserved.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        // Show it
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: - GameOverSceneDelegate

extension GameViewController: GameOverSceneDelegate {

    func gameOverSceneDidTapRestartButton(_ gameOverScene: GameOverScene) {
        // TODO: Remove game over scene here
        startNewGame(animated: true)
    }

}

private extension Double {
    static let sceneTransitionDuration: Double = 0.2
}
