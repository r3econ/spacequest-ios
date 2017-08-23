import SpriteKit


class Spaceship: SKSpriteNode, LifePointsProtocol
{
    var didRunOutOfLifePointsEventHandler: DidRunOutOfLifePointsEventHandler? = nil
    
    var lifePoints: Int = 0
    {
    didSet
    {
        if lifePoints <= 0
        {
            if didRunOutOfLifePointsEventHandler != nil
            {
                didRunOutOfLifePointsEventHandler!(self)
            }
        }
    }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    required override init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
}
