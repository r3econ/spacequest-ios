import UIKit
import SpriteKit


let kSceneTransistionDuration: Double = 0.2


class GameViewController: UIViewController
{
    var gameScene: GameScene?
    var mainMenuScene: MainMenuScene?
    var gameOverScene: GameOverScene?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureView()
        startNewGame(animated: false)
    }
    
    
    override func shouldAutorotate() -> Bool
    {
        return true
    }

    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }

    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}


/**
 Scene handling.
*/
extension GameViewController : GameSceneDelegate, MainMenuSceneDelegate, GameOverSceneDelegate
{
    func startNewGame(#animated: Bool)
    {
        let skView = self.view as SKView
        
        gameScene = GameScene(size: skView.frame.size)
        gameScene!.scaleMode = .AspectFill
        gameScene!.gameSceneDelegate = self
        
        if animated
        {
            skView.presentScene(gameScene!, transition: SKTransition.crossFadeWithDuration(kSceneTransistionDuration))
        }
        else
        {
            skView.presentScene(gameScene!)
        }
    }
    
    
    func resumeGame(#animated: Bool)
    {
        let skView = self.view as SKView
        
        if animated
        {
            skView.presentScene(gameScene!, transition: SKTransition.crossFadeWithDuration(kSceneTransistionDuration))
            
            let delay = kSceneTransistionDuration * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue(),
                {
                    self.mainMenuScene!.removeFromParent()
                    self.gameScene!.paused = false
                })
        }
        else
        {
            skView.presentScene(gameScene!)
            mainMenuScene!.removeFromParent()
        }
    }
    
    
    func showMainMenuScene(#animated: Bool)
    {
        let skView = self.view as SKView
        
        mainMenuScene = MainMenuScene(size: skView.frame.size)
        mainMenuScene!.scaleMode = .AspectFill
        mainMenuScene!.mainMenuSceneDelegate = self
        
        gameScene!.paused = true
        
        if animated
        {
            skView.presentScene(mainMenuScene!, transition: SKTransition.crossFadeWithDuration(kSceneTransistionDuration))
        }
        else
        {
            skView.presentScene(mainMenuScene!)
        }
    }
    
    
    func showGameOverScene(#animated: Bool)
    {
        let skView = self.view as SKView
        
        gameOverScene = GameOverScene(size: skView.frame.size)
        gameOverScene!.scaleMode = .AspectFill
        gameOverScene!.gameOverSceneDelegate = self
        
        gameScene!.paused = true
        
        if animated
        {
            skView.presentScene(gameOverScene!, transition: SKTransition.crossFadeWithDuration(kSceneTransistionDuration))
        }
        else
        {
            skView.presentScene(gameOverScene!)
        }
    }
    
    
    // GameSceneDelegate
    func gameSceneDidTapMainMenuButton(gameScene: GameScene)
    {
        showMainMenuScene(animated: true)
    }
    
    
    func gameScene(gameScene: GameScene, playerDidLoseWithScore: Int)
    {
        showGameOverScene(animated: true)
    }
    
    
    // MainMenuSceneDelegate
    func mainMenuSceneDidTapResumeButton(mainMenuScene: MainMenuScene)
    {
        resumeGame(animated: true)
    }
    
    
    func mainMenuSceneDidTapRestartButton(mainMenuScene: MainMenuScene)
    {
        startNewGame(animated: true)
    }
    
    
    // GameOverSceneDelegate
    func gameOverSceneDidTapRestartButton(gameOverScene:GameOverScene)
    {
        startNewGame(animated: true)
    }
}


/**
 Configuration.
*/
extension GameViewController
{
    func configureView()
    {
        let skView = self.view as SKView
        
        skView.ignoresSiblingOrder = true
        
        // Debugging.
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
    }
}