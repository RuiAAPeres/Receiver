/// Same approach here: https://stackoverflow.com/questions/33436199/add-constraints-to-generic-parameters-in-extension
/// Taken from here: https://github.com/ReactiveCocoa/ReactiveSwift/blob/59b55e9b9de06e7377f3348414ea96f810f487a7/Sources/Optional.swift
public protocol OptionalProtocol {
    /// The type contained in the otpional.
    associatedtype Wrapped

    /// Extracts an optional from the receiver.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Wrapped? {
        return self
    }
}
