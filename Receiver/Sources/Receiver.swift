public protocol Receivable {
    associatedtype Wave
    func listen(to handle: @escaping (Wave) -> Void)
}

public protocol Transmittable {
    associatedtype Wave
    func broadcast(_ wave: Wave)
}

public class Receiver<Wave>: Receivable {

    public typealias Handler = (Wave) -> Void

    private let _currentValue = Atomic<Wave?>(nil)
    private let strategy: Strategy
    private let handlers: Atomic<[Handler]>

    fileprivate var currentValue: Wave? {
        get {
            return _currentValue.value
        }

        set(newValue) {
            guard let value = newValue else { return }
            _currentValue.value = value

            handlers.apply { _handlers in
                _handlers.forEach {
                    $0(value)
                }
            }
        }
    }

    private init(strategy: Strategy) {
        self.handlers = Atomic<[Handler]>([])
        self.strategy = strategy
    }

    public static func make(with strategy: Strategy = .onlyNewValues)
        -> (Receiver.Transmitter, Receiver) {
        let receiver = Receiver(strategy: strategy)
        let transmitter = Receiver<Wave>.Transmitter(receiver)

        return (transmitter, receiver)
    }

    public func listen(to handle: @escaping (Wave) -> Void) {
        handlers.apply { _handlers in
            _handlers.append(handle)

            switch (strategy, currentValue) {
            case (.sendLastValue, let .some(value)):
                handle(value)
            default: break
            }
        }
    }
}

public extension Receiver {
    enum Strategy {
        case sendLastValue
        case onlyNewValues
    }
}

public extension Receiver {
    struct Transmitter: Transmittable {
        private weak var receiver: Receiver?

        init(_ receiver: Receiver) {
            self.receiver = receiver
        }

        public func broadcast(_ wave: Wave) {
            receiver?.currentValue = wave
        }
    }
}
