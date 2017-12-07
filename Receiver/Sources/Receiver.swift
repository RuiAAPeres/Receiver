/// The read only implementation of the Observer pattern.
/// Consumers use the `listen` method and provide a suitable handler that will
/// be called every time a new value (`Wave`) is forward.
/// A Receiver is always created as a pair with its
/// write only counter part: Transmitter.
///
/// By default it has `hot` semantics (as a strategy):
///
/// hot: Before receiving any new values, a handler needs to be provided:
///
/// ```
///    let (transmitter, receiver) = Receiver<Int>.make()
///
///     /// `1` is discarded, since there is no listener
///     transmitter.broadcast(1)
///
///     receiver.listen { value in
///     /// `2` is forwarded, since there is a listener
///     }
///
///     transmitter.broadcast(2)
/// ```
///
/// warm: Will forward previous values (up to the provided value) to the
///       handler once it is provided:
///
/// ```
///     let (transmitter, receiver) = Receiver<Int>.make(with: .warm(upTo: 1))
///
///     /// `1` is discarded, since the limit is `1` (`.warm(upTo: 1)`)
///     transmitter.broadcast(1)
///     /// `2` is stored, until there is an observer
///     transmitter.broadcast(2)
///
///     receiver.listen { value in
///     /// `2` is forwarded, since a listener was added
///     /// `3` is forwarded, since a listener exists
///     }
///
///     transmitter.broadcast(3)
/// ```
///
/// cold: Will forward all the previous values, once the handler is provided:
///
/// ```
///     let (transmitter, receiver) = Receiver<Int>.make(with: .cold)
///
///     /// `1` is stored, until there is an observer
///     transmitter.broadcast(1)
///     /// `2` is stored, until there is an observer
///     transmitter.broadcast(2)
///
///     receiver.listen { value in
///     /// `1` is forwarded, since a listener was added
///     /// `2` is forwarded, since a listener was added
///     /// `3` is forwarded, since a listener exists
///     }
///
///     transmitter.broadcast(3)
/// ```
///
/// For more examples, please check the `ReceiverTests/ReceiverTests.swift` file.
///
/// Note: Providing `.warm(upTo: Int.max)` will have the same meaning as `.cold`.
public class Receiver<Wave> {

    public typealias Handler = (Wave) -> Void

    private let values = Atomic<[Wave]>([])
    private let strategy: Strategy
    private let handlers = Atomic<[Int:Handler]>([:])

    private init(strategy: Strategy) {
        self.strategy = strategy
    }

    private func broadcast(elements: Int) {
        values.apply { _values in

            let lowerLimit = max(_values.count - elements, 0)
            let indexs = (lowerLimit ..< _values.count)

            for index in indexs {
                let value = _values[index]
                handlers.apply { _handlers in
                    for _handler in _handlers.values {
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

    /// Adds a listener to the receiver.
    ///
    /// - parameters:
    ///   - handle: An anonymous function that gets called every time a
    ///             a new value is sent.
    /// - returns: A reference to a disposable
    @discardableResult public func listen(to handle: @escaping (Wave) -> Void) -> Disposable {
        var _key: Int!
        handlers.apply { _handlers in
            _key = (_handlers.keys.map { $0.hashValue }.max() ?? -1) + 1
            _handlers[_key] = handle
        }

        switch strategy {
        case .cold:
            broadcast(elements: Int.max)
        case let .warm(upTo: limit):
            broadcast(elements: limit)
        case .hot:
            broadcast(elements: 0)
        }

        return Disposable {[weak self] in
            self?.handlers.apply { _handlers in
                _handlers[_key] = nil
            }
        }
    }

    /// Factory method to create the pair `transmitter` and `receiver`.
    ///
    /// - parameters:
    ///   - strategy: The strategy that modifies the Receiver's behaviour
    ///               By default it's `hot`.
    public static func make(with strategy: Strategy = .hot)
        -> (Receiver.Transmitter, Receiver) {
            let receiver = Receiver(strategy: strategy)
            let transmitter = Receiver<Wave>.Transmitter(receiver)

            return (transmitter, receiver)
    }
}

extension Receiver {
    /// Enum that represents the Receiver's strategies
    public enum Strategy {
        case cold
        case warm(upTo: Int)
        case hot
    }
}

extension Receiver {
    /// The write only implementation of the Observer pattern.
    /// Used to broadcast values (`Wave`) that will be observed by the `receiver`
    /// and forward to all its listeners.
    ///
    /// Note: Keep in mind that the `transmitter` will hold strongly
    ///       to its `receiver`.
    public struct Transmitter {
        private let receiver: Receiver

        internal init(_ receiver: Receiver) {
            self.receiver = receiver
        }

        /// Used to forward values to the associated `receiver`.
        ///
        /// - parameters:
        ///   - wave: The value to be forward
        public func broadcast(_ wave: Wave) {
            receiver.append(value: wave)
        }
    }
}

/// Used to remove the handler from being called again (aka dispose of),
/// when you invoke `receiver.listen(handler)`.
/// Example:
///
/// Your Receiver is shared across multiple screens (or entities) and one
/// of those, stops existing. In this scenario,
/// you would call `diposable.dispose()` at `deinit` time.
public class Disposable {
    private let cleanUp: () -> Void
    
    internal init(_ cleanUp: @escaping () -> Void) {
        self.cleanUp = cleanUp
    }
    
    /// Used to dispose of the handler passed to the receiver.
    public func dispose() {
        cleanUp()
    }
    
    /// Used to add disposable to the bag to be disposed of later
    public func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}

/// Used to keep a list of Disposable to dispose of them later
/// Example:
///
/// In a UIViewController, you have several Receivers. You create a DisposeBag.
/// When the UIViewController is deinit, the DisposeBag is deinit too. When
/// the DisposeBag is deinit, all disposables will be disposed of.
/// ```
///     private let disposeBag = DisposeBag()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         receiver.listen { value in
///         //// Do whatever
///         }.disposed(by: disposeBag)
///     }
/// ```
/// No need to keep a reference to the Disposable. No need to call dispose() on
/// the disposable. It is disposed by the DisposeBag.
/// You can add multiple disposable to the DisposeBag.
public class DisposeBag {
    /// Keep a reference to all Disposable instances -> this is the actual bag
    private let disposables = Atomic<[Disposable]>([])
    
    /// To be able to create a bag
    public init() {}
    
    /// Called by a Disposable instance
    fileprivate func insert(_ disposable: Disposable) {
        disposables.apply { _disposables in
            _disposables.append(disposable)
        }
    }
    
    /// Clean everything when the bag is deinited by calling dispose()
    /// on all Disposable instances
    deinit {
        disposables.apply { _disposables in
            _disposables.forEach { $0.dispose() }
        }
    }
}

