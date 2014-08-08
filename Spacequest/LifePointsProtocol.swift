import UIKit

typealias DidRunOutOfLifePointsEventHandler = () -> ()

protocol LifePointsProtocol
{
    var lifePoints: Int { get set }
    var didRunOutOfLifePointsEventHandler: DidRunOutOfLifePointsEventHandler? { get set }
}