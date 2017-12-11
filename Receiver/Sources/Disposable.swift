import Foundation

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
