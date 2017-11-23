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
}
