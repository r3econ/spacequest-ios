
typealias DidRunOutOfLifePointsEventHandler = (_ object: AnyObject) -> ()

protocol LifePointsProtocol {
    
    var lifePoints: Int { get set }
    var didRunOutOfLifePointsEventHandler: DidRunOutOfLifePointsEventHandler? { get set }
    
}
