import SpriteKit


protocol GameOverSceneDelegate
{
    func gameOverSceneDidTapRestartButton(gameOverScene:GameOverScene)
}


class GameOverScene: SKScene
{
    var restartButton: Button?
    var buttons: [Button]?
    var gameOverSceneDelegate: GameOverSceneDelegate?
    var background: BackgroundNode?
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        configureButtons()
        configureBackground()
    }
    
    
    func configureBackground()
    {
        background = BackgroundNode(size: self.size, staticBackgroundImageName: ImageName.MenuBackgroundPhone)
        background!.configureInScene(self)
    }
}


/**
Buttons & Title.
*/
extension GameOverScene
    {
    func configureButtons()
    {
        // Restart button.
        restartButton = Button(
            normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonRestartNormal.rawValue)
        
        restartButton!.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()
        
        buttons = [restartButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in enumerate(buttons!)
        {
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != buttons!.count - 1 ? horizontalPadding : 0.0
        }
        
        // Calculate origin of first button.
        var buttonOriginX = CGRectGetWidth(self.frame) / 2.0 + totalButtonsWidth / 2.0
        
        // Place buttons in the scene.
        for (index, button) in enumerate(buttons!)
        {
            button.position = CGPoint(
                x: buttonOriginX - button.size.width/2,
                y: button.size.height * 1.1)
            
            self.addChild(button)
            
            buttonOriginX -= button.size.width + horizontalPadding
            
            let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversedAction()])
            
            button.runAction(SKAction.repeatActionForever(sequence))
        }
    }
    
    
    func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler
    {
        let handler =
        {
            () -> () in
            
            self.gameOverSceneDelegate?.gameOverSceneDidTapRestartButton(self)
            return
        }
        
        return handler
    }
}