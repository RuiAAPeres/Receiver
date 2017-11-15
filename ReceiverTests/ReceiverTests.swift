import XCTest
@testable import Receiver

class ReceiverTests: XCTestCase {

    func test_OneListener_OneSender() {
        let (transmitter, receiver) = Receiver<Int>.make()
        var called = 0

        receiver.listen { wave in
            XCTAssertTrue(wave == 1)
            called = called + 1
        }

        transmitter.broadcast(1)
        XCTAssertTrue(called == 1)
    }

    func test_MultipleListeners_OneSender() {
        let (transmitter, receiver) = Receiver<Int>.make()
        var called = 0

        for _ in 1...5 {
            receiver.listen { wave in
                XCTAssertTrue(wave == 1)
                called = called + 1
            }
        }

        transmitter.broadcast(1)
        XCTAssertTrue(called == 5)

        transmitter.broadcast(1)
        XCTAssertTrue(called == 10)
    }
}
