import XCTest
@testable import Receiver

class ReceiverTests_Operators: XCTestCase {
    
    func test_map() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.map(String.init)
        var called = 0

        newReceiver.listen { wave in
            XCTAssertTrue(wave == "1")
            called = called + 1
        }
        
        transmitter.broadcast(1)
        XCTAssertTrue(called == 1)
    }

    func test_filter() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.filter { $0 % 2 == 0}
        var called = 0

        newReceiver.listen { wave in
            XCTAssertTrue(wave == 2)
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(2)
        transmitter.broadcast(3)

        XCTAssertTrue(called == 1)
    }
}
