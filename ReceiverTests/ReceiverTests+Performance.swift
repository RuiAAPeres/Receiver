import XCTest
@testable import Receiver

class ReceiverTests_Performance: XCTestCase {

    func test_map_filter_performance() {
        // at ~`0.192`
        self.measure {
            let (transmitter, receiver) = Receiver<Int>.make()
            let newReceiver = receiver
                .map { $0 * 3 }
                .filter { $0 / 2 > 0}
                .map { $0 * 3 }

            for i in 1...1000 {
                newReceiver.listen { _ in }
                transmitter.broadcast(i)
            }
        }
    }
}
