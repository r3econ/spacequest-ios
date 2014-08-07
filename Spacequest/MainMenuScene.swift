import SpriteKit


protocol MainMenuSceneDelegate
{
    func mainMenuSceneDidTapResumeButton(mainMenuScene:MainMenuScene)
    func mainMenuSceneDidTapRestartButton(mainMenuScene:MainMenuScene)
}


class MainMenuScene: SKScene
{
    var resumeButton: Button?
    var restartButton: Button?
    var titleNode: SKSpriteNode?
    var buttons: [Button]?
    var mainMenuSceneDelegate: MainMenuSceneDelegate?
    var background: BackgroundNode?

    
    init(size: CGSize)
    {
        super.init(size: size)
                
        configureTitle()
        configureButtons()
        configureBackground()
    }
    
    
    func configureBackground()
    {
        background = BackgroundNode(size: self.size, backgroundImageName: ImageName.MenuBackgroundPhone)
        background!.configureInScene(self)
    }
}


/**
 Buttons & Title.
*/
extension MainMenuScene
{
    func configureButtons()
    {
        // Resume button.
        resumeButton = Button(
            normalImageNamed: ImageName.MenuButtonResumeNormal.toRaw(),
            selectedImageNamed: ImageName.MenuButtonResumeNormal.toRaw())
        
        resumeButton!.touchUpInsideEventHandler = resumeButtonTouchUpInsideHandler()
        
        // Restart button.
        restartButton = Button(
            normalImageNamed: ImageName.MenuButtonRestartNormal.toRaw(),
            selectedImageNamed: ImageName.MenuButtonRestartNormal.toRaw())
        
        restartButton!.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()

        buttons = [resumeButton!, restartButton!]
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
    
    
    func resumeButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler
    {
        let handler =
        {
            () -> () in

            self.mainMenuSceneDelegate?.mainMenuSceneDidTapResumeButton(self)
            return
        }
       
        return handler
    }
    
    
    func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler
    {
        let handler =
        {
            () -> () in
            
            self.mainMenuSceneDelegate?.mainMenuSceneDidTapRestartButton(self)
            return
        }
        
        return handler
    }
    
    
    func configureTitle()
    {
        
    }
}