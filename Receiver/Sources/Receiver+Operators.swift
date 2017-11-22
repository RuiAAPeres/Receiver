extension Receiver {
    func map<U>(_ f: @escaping (Wave) -> U) -> Receiver<U> {
        let (transmitter, receiver) = Receiver<U>.make()
        
        self.listen {
            transmitter.broadcast(f($0))
        }
        
        return receiver
    }
}
