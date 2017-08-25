import SpriteKit

protocol MainMenuSceneDelegate: class {
    
    func mainMenuSceneDidTapResumeButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapRestartButton(_ mainMenuScene: MainMenuScene)
    func mainMenuSceneDidTapInfoButton(_ mainMenuScene: MainMenuScene)
}

class MainMenuScene: SKScene {
    
    fileprivate var infoButton: Button?
    fileprivate var resumeButton: Button?
    fileprivate var restartButton: Button?
    fileprivate var buttons: [Button]?
    fileprivate var background: BackgroundNode?
    weak var mainMenuSceneDelegate: MainMenuSceneDelegate?

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.configureButtons()
        self.configureBackground()
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Track event
        AnalyticsManager.sharedInstance.trackScene("MainMenuScene")
    }
    
}

// MARK: - Configuration

extension MainMenuScene{

    fileprivate func configureBackground() {
        self.background = BackgroundNode(size: self.size, staticBackgroundImageName: ImageName.MenuBackgroundPhone)
        self.background!.configureInScene(self)
    }
    
    fileprivate func configureButtons() {
        
        // Info button.
        self.infoButton = Button(
            normalImageNamed: ImageName.MenuButtonInfoNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonInfoNormal.rawValue)
        
        self.infoButton!.touchUpInsideEventHandler = infoButtonTouchUpInsideHandler()

        self.infoButton!.position = CGPoint(
            x: scene!.size.width - 40.0,
            y: scene!.size.height - 25.0)
        
        self.addChild(self.infoButton!)

        // Resume button.
        self.resumeButton = Button(
            normalImageNamed: ImageName.MenuButtonResumeNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonResumeNormal.rawValue)
        
        self.resumeButton!.touchUpInsideEventHandler = resumeButtonTouchUpInsideHandler()
        
        // Restart button.
        self.restartButton = Button(
            normalImageNamed: ImageName.MenuButtonRestartNormal.rawValue,
            selectedImageNamed: ImageName.MenuButtonRestartNormal.rawValue)
        
        self.restartButton!.touchUpInsideEventHandler = restartButtonTouchUpInsideHandler()
        
        self.buttons = [self.resumeButton!, self.restartButton!]
        let horizontalPadding: CGFloat = 20.0
        var totalButtonsWidth: CGFloat = 0.0
        
        // Calculate total width of the buttons area.
        for (index, button) in (buttons!).enumerated() {
            totalButtonsWidth += button.size.width
            totalButtonsWidth += index != buttons!.count - 1 ? horizontalPadding : 0.0
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
    
    fileprivate func resumeButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { () -> () in
            self.mainMenuSceneDelegate?.mainMenuSceneDidTapResumeButton(self)
            return
        }
    }
    
    fileprivate func restartButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { () -> () in
            self.mainMenuSceneDelegate?.mainMenuSceneDidTapRestartButton(self)
            return
        }
    }
    
    fileprivate func infoButtonTouchUpInsideHandler() -> TouchUpInsideEventHandler {
        return { () -> () in
            self.mainMenuSceneDelegate?.mainMenuSceneDidTapInfoButton(self)
            return
        }
    }
    
}
