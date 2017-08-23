import SpriteKit

protocol GameOverSceneDelegate {
    func gameOverSceneDidTapRestartButton(_ gameOverScene: GameOverScene)
}

class GameOverScene: SKScene{

    var restartButton: Button?
    var buttons: [Button]?
    var gameOverSceneDelegate: GameOverSceneDelegate?
    var background: BackgroundNode?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.configureButtons()
        self.configureBackground()
    }
    
    func configureBackground() {
        self.background = BackgroundNode(size: self.size, staticBackgroundImageName: ImageName.MenuBackgroundPhone)
        self.background!.configureInScene(self)
    }
    
    override func didMove(to view: SKView) {
        AnalyticsManager.sharedInstance.trackScene("GameOverScene")
    }
    
}

extension GameOverScene {
    
    func configureButtons() {
        // Restart button
        self.restartButton = Button(
            normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonRestartNormal.rawValue)
        
        self.restartButton!.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()
        
        self.buttons = [self.restartButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in (self.buttons!).enumerated() {
            
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != self.buttons!.count - 1 ? horizontalPadding : 0.0
        }
        
        // Calculate origin of first button.
        var buttonOriginX = self.frame.width / 2.0 + totalButtonsWidth / 2.0
        
        // Place buttons in the scene.
        for (_, button) in (self.buttons!).enumerated() {
            button.position = CGPoint(
                x: buttonOriginX - button.size.width/2,
                y: button.size.height * 1.1)
            
            self.addChild(button)
            
            buttonOriginX -= button.size.width + horizontalPadding
            
            let rotateAction = SKAction.rotate(byAngle: CGFloat(.pi/180.0 * 5.0), duration: 2.0)
            let sequence = SKAction.sequence([rotateAction, rotateAction.reversed()])
            
            button.run(SKAction.repeatForever(sequence))
        }
    }
    
    func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        let handler = { () -> () in
            self.gameOverSceneDelegate?.gameOverSceneDidTapRestartButton(self)
            return
        }
        
        return handler
    }
    
}
