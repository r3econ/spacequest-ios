import UIKit
import SpriteKit


let kSceneTransistionDuration: Double = 0.2


class GameViewController: UIViewController {
    
    var gameScene: GameScene?
    var mainMenuScene: MainMenuScene?
    var gameOverScene: GameOverScene?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureView()
        startNewGame(animated: false)
        
        toggleBackgroungMusic()
    }
    
    
    override var shouldAutorotate : Bool {
        
        return true
    }

    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.landscape
    }

    
    override var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
}


/**
 Scene handling.
*/
extension GameViewController : GameSceneDelegate, MainMenuSceneDelegate, GameOverSceneDelegate {
    
    func startNewGame(animated: Bool) {
        let skView = self.view as! SKView
        
        gameScene = GameScene(size: skView.frame.size)
        gameScene!.scaleMode = .aspectFill
        gameScene!.gameSceneDelegate = self
        
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
            
            skView.presentScene(gameScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
            
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
            mainMenuScene!.removeFromParent()
        }
    }
    
    
    func showMainMenuScene(animated: Bool) {
        
        let skView = self.view as! SKView
        
        mainMenuScene = MainMenuScene(size: skView.frame.size)
        mainMenuScene!.scaleMode = .aspectFill
        mainMenuScene!.mainMenuSceneDelegate = self
        
        gameScene!.isPaused = true
        
        if animated {
            
            skView.presentScene(mainMenuScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
        }
        else {
            skView.presentScene(mainMenuScene!)
        }
    }
    
    
    func showGameOverScene(animated: Bool) {
        
        let skView = self.view as! SKView
        
        gameOverScene = GameOverScene(size: skView.frame.size)
        gameOverScene!.scaleMode = .aspectFill
        gameOverScene!.gameOverSceneDelegate = self
        
        gameScene!.isPaused = true
        
        if animated
        {
            skView.presentScene(gameOverScene!, transition: SKTransition.crossFade(withDuration: kSceneTransistionDuration))
        }
        else
        {
            skView.presentScene(gameOverScene!)
        }
    }
    
    
    // GameSceneDelegate
    func gameSceneDidTapMainMenuButton(_ gameScene: GameScene) {
        
        showMainMenuScene(animated: true)
    }
    
    
    func gameScene(_ gameScene: GameScene, playerDidLoseWithScore: Int) {
        
        showGameOverScene(animated: true)
    }
    
    
    // MainMenuSceneDelegate
    func mainMenuSceneDidTapResumeButton(_ mainMenuScene: MainMenuScene) {
        
        resumeGame(animated: true)
    }
    
    
    func mainMenuSceneDidTapRestartButton(_ mainMenuScene: MainMenuScene) {
        
        startNewGame(animated: true)
    }
    
    
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene:MainMenuScene) {
        
    }
    
    
    // GameOverSceneDelegate
    func gameOverSceneDidTapRestartButton(_ gameOverScene:GameOverScene) {
        
        startNewGame(animated: true)
    }
}


/**
 Configuration.
*/
extension GameViewController
{
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
