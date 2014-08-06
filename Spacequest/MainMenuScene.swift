import SpriteKit


class MainMenuScene: SKScene
{
    var resumeButton: Button?
    var restartButton: Button?
    var titleNode: SKSpriteNode?
    var buttons: [Button]?

    
    init(size: CGSize)
    {
        super.init(size: size)
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        configureTitle()
        configureButtons()
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
            normalImageNamed: "menu_button_normal",
            selectedImageNamed: "menu_button_normal")
        
        resumeButton!.title = NSLocalizedString("resume", comment: "")
        resumeButton!.touchUpInsideEventHandler = resumeButtonTouchUpInsideHandler()
        
        // Restart button.
        restartButton = Button(
            normalImageNamed: "menu_button_normal",
            selectedImageNamed: "menu_button_normal")
        
        restartButton!.title = NSLocalizedString("restart", comment: "")
        restartButton!.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()

        buttons = [resumeButton!, restartButton!]
        let verticalPadding = 20.0
        var totalButtonsHeight = 0.0
        
        // Calculate total height of the buttons area.
        for (index, button) in enumerate(buttons!)
        {
            totalButtonsHeight += button.size.height
            totalButtonsHeight += index != buttons!.count - 1 ? verticalPadding : 0.0
        }
        
        // Calculate origin of first button.
        var buttonOriginY = CGRectGetHeight(self.frame) / 2 + totalButtonsHeight / 2
        
        // Place buttons in the scene.
        for (index, button) in enumerate(buttons!)
        {
            button.position = CGPoint(
                x: CGRectGetWidth(self.frame)/2,
                y: buttonOriginY - button.size.height/2)
            
            self.addChild(button)
            
            buttonOriginY -= button.size.height + verticalPadding
        }
    }
    
    
    func resumeButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler
    {
        let handler =
        {
            () -> () in

            
        }
       
        return handler
    }
    
    
    func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler
    {
        let handler =
        {
            () -> () in
            
        }
        
        return handler
    }
    
    
    func configureTitle()
    {
        
    }
}