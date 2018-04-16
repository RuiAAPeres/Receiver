/// Taken and edited from https://github.com/ReactiveCocoa/ReactiveSwift/blob/master/Sources/Atomic.swift
import Foundation

private class UnfairLock {
    private let _lock: os_unfair_lock_t

    fileprivate init() {
        _lock = .allocate(capacity: 1)
        _lock.initialize(to: os_unfair_lock())
    }

    fileprivate func lock() {
        os_unfair_lock_lock(_lock)
    }

    fileprivate func unlock() {
        os_unfair_lock_unlock(_lock)
    }

    deinit {
        _lock.deallocate()
    }
}

internal class Atomic<Value> {
    private let lock = UnfairLock()
    private var _value: Value

    internal init(_ value: Value) {
        _value = value
    }

    internal func apply(_ action: (inout Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        action(&_value)
    }
}
