import SpriteKit


class GamePausedScene: SKScene
{
    var resumeButton: Button?

    init(size: CGSize)
    {
        super.init(size: size)
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        configureButtons()
    }
    
    func configureButtons()
    {
        
    }
}
