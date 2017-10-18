import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    fileprivate struct Constants {
        static let sceneTransistionDuration: Double = 0.2
    }
    
    var gameScene: GameScene?
    
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

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

// MARK: - Scene handling

extension GameViewController {
    
    fileprivate func startNewGame(animated: Bool = false) {
        // Recreate game scene
        self.gameScene = GameScene(size: self.view.frame.size)
        self.gameScene!.scaleMode = .aspectFill
        self.gameScene!.gameSceneDelegate = self
        
        self.showScene(self.gameScene!, animated: animated)
    }
    
    fileprivate func resumeGame(animated: Bool = false, completion:(()->())? = nil) {
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
    
    fileprivate func showMainMenuScene(animated: Bool) {
        // Create main menu scene
        let scene = MainMenuScene(size: self.view.frame.size)
        scene.scaleMode = .aspectFill
        scene.mainMenuSceneDelegate = self
        
        // Pause the game
        self.gameScene!.isPaused = true
        
        // Show it
        self.showScene(scene, animated: animated)
    }
    
    fileprivate func showGameOverScene(animated: Bool) {
        // Create game over scene
        let scene = GameOverScene(size: self.view.frame.size)
        scene.scaleMode = .aspectFill
        scene.gameOverSceneDelegate = self
        
        // Pause the game
        self.gameScene!.isPaused = true
        
        // Show it
        self.showScene(scene, animated: animated)
    }

    fileprivate func showScene(_ scene: SKScene, animated: Bool) {
        let skView = self.view as! SKView
        
        if animated {
            skView.presentScene(scene, transition: SKTransition.crossFade(withDuration: Constants.sceneTransistionDuration))
        }
        else {
            skView.presentScene(scene)
        }
    }
    
}

// MARK: - GameSceneDelegate

extension GameViewController : GameSceneDelegate {

    func gameSceneDidTapMainMenuButton(_ gameScene: GameScene) {
        // Show initial, main menu scene
        self.showMainMenuScene(animated: true)
    }
    
    func gameScene(_ gameScene: GameScene, playerDidLoseWithScore: Int) {
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
    
    fileprivate func configureView() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        // Enable debugging
        #if DEBUG
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
        #endif
    }
    
}
