import SpriteKit


class GamePausedScene: SKScene
{
    var resumeButton: Button?
    var restartButton: Button?
    var buttons: [Button]?

    
    init(size: CGSize)
    {
        super.init(size: size)
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        configureButtons()
    }
    
    
    func configureButtons()
    {
        // Resume button.
        resumeButton = Button(
            normalImageNamed: "menu_button_normal",
            selectedImageNamed: "menu_button_normal")

        resumeButton!.title = NSLocalizedString("resume", comment: "")
        
        // Restart button.
        
        buttons = [resumeButton!, restartButton!]
        resumeButton = Button(
            normalImageNamed: "menu_button_normal",
            selectedImageNamed: "menu_button_normal")
        resumeButton!.position = CGPoint(
            x: CGRectGetWidth(self.frame)/2,
            y: CGRectGetHeight(self.frame)/2)
        resumeButton!.title = NSLocalizedString("resume", comment: "")
        
        for (index, button) in enumerate(buttons)
        {
            button!.position = CGPoint(
                x: CGRectGetWidth(self.frame)/2,
                y: CGRectGetHeight(self.frame)/2)
            
            self.addChild(button)
        }
    }
}
