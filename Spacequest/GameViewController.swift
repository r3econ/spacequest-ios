import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    fileprivate struct Constants {
        static let sceneTransistionDuration: Double = 0.2
    }
    
    var gameScene: GameScene?
    var mainMenuScene: MainMenuScene?
    var gameOverScene: GameOverScene?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.startNewGame(animated: false)
        
        // Start music
        self.toggleBackgroungMusic()
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
    
    fileprivate func startNewGame(animated: Bool) {
        // Recreate game scene
        self.gameScene = GameScene(size: self.view.frame.size)
        self.gameScene!.scaleMode = .aspectFill
        self.gameScene!.gameSceneDelegate = self
        
        self.showScene(self.gameScene!, animated: animated)
    }
    
    fileprivate func resumeGame(animated: Bool) {
        let skView = self.view as! SKView
        
        if animated {
            // Show game scene
            skView.presentScene(self.gameScene!,
                                transition: SKTransition.crossFade(withDuration: Constants.sceneTransistionDuration))
            
            // Remove the menu scene and unpause the game scene after it was shown
            let delay = Constants.sceneTransistionDuration * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + delay / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] in
                guard let weakSelf = self else { return }
                
                weakSelf.mainMenuScene!.removeFromParent()
                weakSelf.gameScene!.isPaused = false
            })
        }
        else {
            skView.presentScene(self.gameScene!)
            self.mainMenuScene!.removeFromParent()
        }
    }
    
    fileprivate func showMainMenuScene(animated: Bool) {
        // Create main menu scene
        self.mainMenuScene = MainMenuScene(size: self.view.frame.size)
        self.mainMenuScene!.scaleMode = .aspectFill
        self.mainMenuScene!.mainMenuSceneDelegate = self
        
        // Pause the game
        self.gameScene!.isPaused = true
        
        // Show it
        self.showScene(self.mainMenuScene!, animated: animated)
    }
    
    fileprivate func showGameOverScene(animated: Bool) {
        // Create game over scene
        self.gameOverScene = GameOverScene(size: self.view.frame.size)
        self.gameOverScene!.scaleMode = .aspectFill
        self.gameOverScene!.gameOverSceneDelegate = self
        
        // Pause the game
        self.gameScene!.isPaused = true
        
        // Show it
        self.showScene(self.gameOverScene!, animated: animated)
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
        self.resumeGame(animated: true)
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
    
    func gameOverSceneDidTapRestartButton(_ gameOverScene:GameOverScene) {
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
    
    fileprivate func toggleBackgroungMusic() {
        MusicManager.sharedInstance.toggleBackgroundMusic()
    }
    
}
