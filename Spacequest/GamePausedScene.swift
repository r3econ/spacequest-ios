import SpriteKit


class GamePausedScene: SKScene
{
    var resumeButton: Button?
    var buttons: [Button]?

    
    init(size: CGSize)
    {
        super.init(size: size)
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        configureButtons()
    }
    
    
    func configureButtons()
    {
        resumeButton = Button(
            normalImageNamed: "menu_button_normal",
            selectedImageNamed: "menu_button_normal")
        resumeButton!.position = CGPoint(
            x: CGRectGetWidth(self.frame)/2,
            y: CGRectGetHeight(self.frame)/2)
        resumeButton!.titleLabelNode
        buttons = [resumeButton!]
        
        self.addChild(resumeButton)
    }
}
