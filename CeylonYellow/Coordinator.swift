import RxSwift

public protocol CoordinatorProtocol: class {

}

public protocol CoordinatorNode: CoordinatorProtocol {
    associatedtype Result

    func start() -> Single<Result>
}

public class Coordinator<Result>: CoordinatorNode {
    var tree = [CoordinatorProtocol]()

    public init() {

    }

    public func start() -> Single<Result> {
        return .never()
    }

    public func startChild<Coordinator: CoordinatorNode>(_ coordinator: Coordinator) -> Single<Coordinator.Result> {

        return coordinator.start()
            .do(onSubscribe: {[weak self] in
                guard let self = self else { return }
                if !self.tree.contains(where: { $0 === coordinator }) {
                    self.tree.append(coordinator)
                }
            },
            onDispose: { [weak self] in
                guard let self = self else { return }

                self.tree = self.tree.filter { $0 !== coordinator }
            })
    }
}
