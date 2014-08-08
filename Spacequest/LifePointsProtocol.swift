import UIKit

typealias DidRunOutOfLifePointsEventHandler = (object: AnyObject) -> ()

protocol LifePointsProtocol
{
    var lifePoints: Int { get set }
    var didRunOutOfLifePointsEventHandler: DidRunOutOfLifePointsEventHandler? { get set }
}