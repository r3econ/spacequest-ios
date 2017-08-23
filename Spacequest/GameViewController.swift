import UIKit
import SpriteKit

let kSceneTransistionDuration: Double = 0.2

class GameViewController: UIViewController {
    
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
    
    func startNewGame(animated: Bool) {
        let skView = self.view as! SKView
        
        self.gameScene = GameScene(size: skView.frame.size)
        self.gameScene!.scaleMode = .aspectFill
        self.gameScene!.gameSceneDelegate = self
        
        if animated {
            skView.presentScene(gameScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
        }
        else {
            skView.presentScene(gameScene!)
        }
    }
    func resumeGame(animated: Bool) {
        let skView = self.view as! SKView
        
        if animated {
            skView.presentScene(self.gameScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
            
            let delay = kSceneTransistionDuration * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time,
                                          execute: {
                                            self.mainMenuScene!.removeFromParent()
                                            self.gameScene!.isPaused = false
            })
        }
        else {
            skView.presentScene(gameScene!)
            self.mainMenuScene!.removeFromParent()
        }
    }
    func showMainMenuScene(animated: Bool) {
        let skView = self.view as! SKView
        
        self.mainMenuScene = MainMenuScene(size: skView.frame.size)
        self.mainMenuScene!.scaleMode = .aspectFill
        self.mainMenuScene!.mainMenuSceneDelegate = self
        
        self.gameScene!.isPaused = true
        
        if animated {
            skView.presentScene(self.mainMenuScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
        }
        else {
            skView.presentScene(self.mainMenuScene!)
        }
    }
    
    func showGameOverScene(animated: Bool) {
        let skView = self.view as! SKView
        
        self.gameOverScene = GameOverScene(size: skView.frame.size)
        self.gameOverScene!.scaleMode = .aspectFill
        self.gameOverScene!.gameOverSceneDelegate = self
        
        self.gameScene!.isPaused = true
        
        if animated {
            skView.presentScene(self.gameOverScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
        }
        else {
            skView.presentScene(self.gameOverScene!)
        }
    }

}

// MARK: - GameSceneDelegate

extension GameViewController : GameSceneDelegate {

    func gameSceneDidTapMainMenuButton(_ gameScene: GameScene) {
        self.showMainMenuScene(animated: true)
    }
    func gameScene(_ gameScene: GameScene, playerDidLoseWithScore: Int) {
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
    
    func configureView() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        // Debugging.
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
    }
    func toggleBackgroungMusic() {
        MusicManager.sharedInstance.toggleBackgroundMusic()
    }
    
}
