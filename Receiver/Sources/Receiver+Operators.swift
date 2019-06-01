extension Receiver {
    /// Map each value (`Wave`) sent to the `receiver` to a new value (`U`).
    /// ```
    ///    let (transmitter, receiver) = Receiver<Int>.make()
    ///    let integersToStrings = receiver.map(String.init)
    ///
    ///    integersToStrings.listen { value in
    ///        /// value is `"1"`
    ///    }
    ///
    ///    transmitter.broadcast(1)
    /// ```
    /// - parameters:
    ///   - transform: An anonymous function that accepts the current value type
    ///                (`Wave`) and transforms it to a `U`.
    ///
    /// - returns: A `receiver` with the applied transformation.
    public func map<U>(_ transform: @escaping (Wave) -> U) -> Receiver<U> {
        let (transmitter, receiver) = Receiver<U>.make()
        
        self.listen {
            transmitter.broadcast(transform($0))
        }
        
        return receiver
    }

    /// Filters each value (`Wave`) sent to the `receiver` based on the anonymous
    /// function provided (the predicate).
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int>.make()
    ///     let onlyEvenNumbers = receiver.filter { $0 % 2 == 0}
    ///
    ///     onlyEvenNumbers.listen { value in
    ///     }
    ///
    ///     /// Value is not sent to the listener, because `1` is an odd number
    ///     transmitter.broadcast(1)
    ///     /// Value is sent to the listener, because `2` is an even number
    ///     transmitter.broadcast(2)
    /// ```
    /// - parameters:
    ///   - isIncluded: An anonymous function that acts as a predicate.
    ///                 Only when `true`, the value is forwarded.
    ///
    /// - returns: A `receiver` that discards values based on a predicate.
    public func filter(_ isIncluded: @escaping (Wave) -> Bool) -> Receiver<Wave> {
        let (transmitter, receiver) = Receiver<Wave>.make()

        self.listen {
            guard isIncluded($0) else { return }
            transmitter.broadcast($0)
        }

        return receiver
    }

    /// Bundles each value (`Wave`) sent to the `receiver` with the previous value sent.
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int>.make()
    ///     let newReceiver = receiver.withPrevious()
    ///
    ///     newReceiver.listen { value in
    ///          /// `value` == (nil, 1)
    ///          /// `value` == (1, 2)
    ///     }
    ///
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    /// ```
    ///
    /// - returns: A `receiver` that pairs the previous value with the current.
    public func withPrevious() -> Receiver<(Wave?, Wave)> {
        let (transmitter, receiver) = Receiver<(Wave?, Wave)>.make()
        let values = Atomic<[Wave]>([])

        self.listen { newValue in
            values.apply { _values in

                let previous = _values.last
                _values.append(newValue)

                transmitter.broadcast((previous, newValue))
            }
        }

        return receiver
    }

    /// Skips values up to count, forwarding values normally afterwards.
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int>.make()
    ///     let skippedValues = receiver.skip(count: 3)
    ///
    ///     newReceiver.listen { value in
    ///          /// `value` == 4
    ///     }
    ///
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(3)
    ///     transmitter.broadcast(4)
    /// ```
    /// - parameters:
    ///   - count: The number of values it will skip.
    ///
    /// - returns: A `receiver` that skips values up to `count`.
    public func skip(count: Int) -> Receiver<Wave> {
        guard count > 0 else { return self }

        let (transmitter, receiver) = Receiver<Wave>.make()
        let counter = Atomic<Int>(0)

        self.listen { newValue in
            counter.apply { _counterValue in

                guard _counterValue >= count else {
                    _counterValue = _counterValue + 1
                    return
                }

                transmitter.broadcast(newValue)
            }
        }

        return receiver
    }

    /// Only forwards values up to `count`, skipping all the values afterwards.
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int>.make()
    ///     let takeValues = receiver.take(count: 3)
    ///
    ///     takeValues.listen { value in
    ///          /// `value` == 1
    ///          /// `value` == 2
    ///          /// `value` == 3
    ///     }
    ///
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(3)
    ///     transmitter.broadcast(4)
    /// ```
    /// - parameters:
    ///   - count: The number of values it will forward.
    ///
    /// - returns: A `receiver` that forwards values up to count.
    public func take(count: Int) -> Receiver<Wave> {
        let (transmitter, receiver) = Receiver<Wave>.make()
        let counter = Atomic<Int>(count)

        self.listen { newValue in
            counter.apply { _counterValue in
                guard _counterValue > 0 else { return }
                _counterValue = _counterValue - 1

                transmitter.broadcast(newValue)
            }
        }

        return receiver
    }
}

extension Receiver where Wave: Equatable {
    /// Skips consecutive repeated values.
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int>.make()
    ///     let skipRepeatedValues = receiver.skipRepeats()
    ///
    ///     skipRepeatedValues.listen { value in
    ///          /// `value` == 1
    ///          /// `value` == 2
    ///          /// `value` == 3
    ///          /// `value` == 1
    ///     }
    ///
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(3)
    ///     transmitter.broadcast(1)
    /// ```
    ///
    /// - returns: A `receiver` that skips repeated consecutive values.
    public func skipRepeats() -> Receiver<Wave> {
        let (transmitter, receiver) = Receiver<Wave>.make()
        let values = Atomic<[Wave]>([])

        self.listen { newValue in
            values.apply { _values in

                func f(_ newValue: Wave) {
                    _values.append(newValue)
                    transmitter.broadcast(newValue)
                }

                switch _values.last {
                case let .some(lastValue) where lastValue != newValue:
                    f(newValue)
                case .none:
                    f(newValue)
                default:
                    return
                }
            }
        }

        return receiver
    }
}

extension Receiver where Wave: Hashable {
    /// Only forwards unique values
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int>.make()
    ///     let uniqueValues = receiver.uniqueValues()
    ///
    ///     uniqueValues.listen { value in
    ///          /// `value` == 1
    ///          /// `value` == 2
    ///          /// `value` == 3
    ///     }
    ///
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(3)
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(2)
    /// ```
    ///
    /// - returns: A `receiver` that only forwards unique events.
    public func uniqueValues() -> Receiver<Wave> {
        let (transmitter, receiver) = Receiver<Wave>.make()
        let values = Atomic<Set<Wave>>([])

        self.listen { newValue in
            values.apply { _values in
                guard _values.contains(newValue) == false else { return }

                _values.insert(newValue)
                transmitter.broadcast(newValue)
            }
        }

        return receiver
    }
}

extension Receiver where Wave: OptionalProtocol {
    /// Skips nil values, forwarding only non-nil values
    /// ```
    ///     let (transmitter, receiver) = Receiver<Int?>.make()
    ///     let skipNilValues = receiver.skipNil()
    ///
    ///     skipNilValues.listen { value in
    ///          /// `value` == 1
    ///          /// `value` == 2
    ///          /// `value` == 3
    ///     }
    ///
    ///     transmitter.broadcast(1)
    ///     transmitter.broadcast(1?)
    ///     transmitter.broadcast(2?)
    ///     transmitter.broadcast(2)
    ///     transmitter.broadcast(3)
    /// ```
    ///
    /// - returns: A `receiver` that skips nil values.
    public func skipNil() -> Receiver<Wave.Wrapped> {
        let (transmitter, receiver) = Receiver<Wave.Wrapped>.make()

        self.listen { newValue in
            switch newValue.optional {
            case let .some(_newValue):
                transmitter.broadcast(_newValue)
            case .none:
                return
            }
        }

        return receiver
    }
}

/// Combines a receiver of `A` and a reveiver of `B` to produce a receiver of (A,B)
/// ```
///     let (intTransmitter, intReceiver) = Receiver<Int>.make()
///     let (stringTransmitter, stringReceiver) = Receiver<String>.make()
///
///     let intAndStringReceiver = combine(intReceiver,stringReceiver)
///     }
///
///     intAndStringReceiver.listen { value in
///          /// `value` == (1,"1")
///          /// `value` == (2,"1")
///          /// `value` == (2,"2")
///     }
///     /// Value is not sent yet since we do not have a value from stringReceiver
///     intTransmitter.broadcast(1)
///     /// Value is sent to the listener now as (1,"1")
///     stringTransmitter.broadcast("1")
///     /// Value is sent to the listener now as (2,"2")
///     intTransmitter.broadcast(2)
///     /// Value is sent to the listener now as (2,"2")
///     stringTransmitter.broadcast("2")
/// ```
/// - parameters:
///   - ra: A receiver of type Receiver<A>
///   - rb: A receiver of type Receiver<B>
///
/// - returns: A `receiver` that produces values of <(A,B)> for every value emitted from either
public func combine<A,B>(_ ra: Receiver<A>, _ rb: Receiver<B>) -> Receiver<(A,B)> {
    let (transmitter, receiver) = Receiver<(A?,B?)>.make()
    let ab = Atomic<(A?,B?)>( (nil,nil) )
    
    ra.listen { a in
        ab.apply {
            $0.0 = a
            transmitter.broadcast($0)
            }
        }
    
    rb.listen { b in
        ab.apply {
            $0.1 = b
            transmitter.broadcast($0)
        }
    }
    
    let newReceiver = receiver.map { (ab) -> (A,B)? in
        if let next = ab as? (A,B) {
            return next
        } else {
            return nil
        }
    }.skipNil()

    return newReceiver

}
