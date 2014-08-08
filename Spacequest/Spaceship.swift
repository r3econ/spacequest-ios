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
            if didRunOutOfLifePointsEventHandler
            {
                didRunOutOfLifePointsEventHandler!()
            }
        }
    }
    }
}