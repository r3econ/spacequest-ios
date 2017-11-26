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
    
    private struct Constants {
        static let sceneTransistionDuration: Double = 0.2
    }
    
    private var gameScene: GameScene?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.startNewGame(animated: false)
        
        // Start the background music
        MusicManager.shared.playBackgroundMusic()
    }
    
    // MARK: - Appearance

    override var shouldAutorotate : Bool {
        return true
    }

    // Make sure only the landscape mode is supported
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var prefersStatusBarHidden : Bool {
        // Hide the status bar
        return true
    }
    
}

// MARK: - Scene handling

extension GameViewController {
    
    private func startNewGame(animated: Bool = false) {
        // Recreate game scene
        self.gameScene = GameScene(size: self.view.frame.size)
        self.gameScene!.scaleMode = .aspectFill
        self.gameScene!.gameSceneDelegate = self
        
        self.showScene(self.gameScene!, animated: animated)
    }
    
    private func resumeGame(animated: Bool = false, completion:(()->())? = nil) {
        let skView = self.view as! SKView
        
        if animated {
            // Show game scene
            skView.presentScene(self.gameScene!,
                                transition: SKTransition.crossFade(withDuration: Constants.sceneTransistionDuration))
            
            // Remove the menu scene and unpause the game scene after it was shown
            let delay = Constants.sceneTransistionDuration * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + delay / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] in
                self?.gameScene!.isPaused = false
                
                // Call completion handler
                completion?()
            })
        }
        else {
            // Remove the menu scene and unpause the game scene after it was shown
            skView.presentScene(self.gameScene!)
            self.gameScene!.isPaused = false

            // Call completion handler
            completion?()
        }
    }
    
    private func showMainMenuScene(animated: Bool) {
        // Create main menu scene
        let scene = MainMenuScene(size: self.view.frame.size)
        scene.scaleMode = .aspectFill
        scene.mainMenuSceneDelegate = self
        
        // Pause the game
        self.gameScene!.isPaused = true
        
        // Show it
        self.showScene(scene, animated: animated)
    }
    
    private func showGameOverScene(animated: Bool) {
        // Create game over scene
        let scene = GameOverScene(size: self.view.frame.size)
        scene.scaleMode = .aspectFill
        scene.gameOverSceneDelegate = self
        
        // Pause the game
        self.gameScene!.isPaused = true
        
        // Show it
        self.showScene(scene, animated: animated)
    }

    private func showScene(_ scene: SKScene, animated: Bool) {
        let skView = self.view as! SKView
        
        if animated {
            skView.presentScene(scene, transition: SKTransition.crossFade(withDuration: Constants.sceneTransistionDuration))
        } else {
            skView.presentScene(scene)
        }
    }
    
}

// MARK: - GameSceneDelegate

extension GameViewController : GameSceneDelegate {

    func didTapMainMenuButton(in gameScene: GameScene) {
        // Show initial, main menu scene
        self.showMainMenuScene(animated: true)
    }
    
    func playerDidLose(withScore score: Int, in gameScene:GameScene) {
        // Player lost, show game over scene
        self.showGameOverScene(animated: true)
    }
    
}

// MARK: - MainMenuSceneDelegate

extension GameViewController : MainMenuSceneDelegate {
    
    func mainMenuSceneDidTapResumeButton(_ mainMenuScene: MainMenuScene) {
        self.resumeGame(animated: true) {
            // Remove main menu scene when game is resumed
            mainMenuScene.removeFromParent()
        }
    }
    
    func mainMenuSceneDidTapRestartButton(_ mainMenuScene: MainMenuScene) {
        self.startNewGame(animated: true)
    }
    
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene:MainMenuScene) {
        // TODO: To be implemented
    }
    
}

// MARK: - GameOverSceneDelegate

extension GameViewController : GameOverSceneDelegate {
    
    func gameOverSceneDidTapRestartButton(_ gameOverScene: GameOverScene) {
        // TODO: Remove game over scene here
        self.startNewGame(animated: true)
    }
    
}

// MARK: - Configuration

extension GameViewController {
    
    private func configureView() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        // Enable debugging
        //#if DEBUG
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
        //#endif
    }
    
}
