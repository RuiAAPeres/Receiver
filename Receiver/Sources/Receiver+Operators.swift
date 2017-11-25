extension Receiver {
    func map<U>(_ f: @escaping (Wave) -> U) -> Receiver<U> {
        let (transmitter, receiver) = Receiver<U>.make()
        
        self.listen {
            transmitter.broadcast(f($0))
        }
        
        return receiver
    }

    func filter(_ isIncluded: @escaping (Wave) -> Bool) -> Receiver<Wave> {
        let (transmitter, receiver) = Receiver<Wave>.make()

        self.listen {
            guard isIncluded($0) else { return }
            transmitter.broadcast($0)
        }

        return receiver
    }

    func withPrevious() -> Receiver<(Wave?, Wave)> {
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

    func skip(count: Int) -> Receiver<Wave> {
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

    func take(count: Int) -> Receiver<Wave> {
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
    func skipRepeats() -> Receiver<Wave> {
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
