import SpriteKit

class Spaceship: SKSpriteNode, LifePointsProtocol {
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    // MARK: - LifePointsProtocol
    
    var didRunOutOfLifePointsEventHandler: DidRunOutOfLifePointsEventHandler? = nil
    
    var lifePoints: Int = 0 {
        didSet {
            if self.lifePoints <= 0 {
                self.didRunOutOfLifePointsEventHandler?(self)
            }
        }
    }
    
}
