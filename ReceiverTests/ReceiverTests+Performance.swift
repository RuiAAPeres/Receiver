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
    
    func test_listen_performance() {
        self.measure {
            let numberOfListeners = 200000
            let (transmitter, receiver) = Receiver<Int>.make()
            var called = 0
            
            for _ in 1...numberOfListeners {
                receiver.listen { wave in
                    XCTAssertTrue(wave == 1)
                    called = called + 1
                }
            }
            
            transmitter.broadcast(1)
            XCTAssertEqual(called, numberOfListeners)

            transmitter.broadcast(1)
            XCTAssertEqual(called, numberOfListeners*2)
        }
    }

}
