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

    private let values = Atomic<[Wave]>([])
    private let strategy: Strategy
    private let handlers: Atomic<[Handler]>

    private init(strategy: Strategy) {
        self.handlers = Atomic<[Handler]>([])
        self.strategy = strategy
    }

    private func broadcast(elements: Int) {
        values.apply { _values in

            let lowerLimit = max(_values.count - elements, 0)
            let indexs = (lowerLimit ..< _values.count)

            indexs.forEach { index in
                let value = _values[index]
                handlers.apply { _handlers in
                    _handlers.forEach { _handler in
                        _handler(value)
                    }
                }
            }
        }
    }

    fileprivate func append(value: Wave) {
        values.apply { currentValues in
            currentValues.append(value)
        }
        broadcast(elements: 1)
    }

    public func listen(to handle: @escaping (Wave) -> Void) {
        handlers.apply { _handlers in
            _handlers.append(handle)
        }
        switch strategy {
        case .cold:
            broadcast(elements: Int.max)
        case let .warm(upTo: limit):
            broadcast(elements: limit)
        case .hot:
            broadcast(elements: 0)
        }
    }

    public static func make(with strategy: Strategy = .hot)
        -> (Receiver.Transmitter, Receiver) {
            let receiver = Receiver(strategy: strategy)
            let transmitter = Receiver<Wave>.Transmitter(receiver)

            return (transmitter, receiver)
    }
}

public extension Receiver {
    enum Strategy {
        case cold
        case warm(upTo: Int)
        case hot
    }
}

public extension Receiver {
    struct Transmitter: Transmittable {
        private weak var receiver: Receiver?

        init(_ receiver: Receiver) {
            self.receiver = receiver
        }

        public func broadcast(_ wave: Wave) {
            receiver?.append(value: wave)
        }
    }
}
