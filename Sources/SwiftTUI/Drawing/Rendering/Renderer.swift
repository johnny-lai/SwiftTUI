import Foundation

public protocol Renderer: AnyObject {
    var application: Application? { get set }

    //var windowSize: Size { get set }

    func start()
    func stop()

    func update()

    func didChangeLayer()
}

