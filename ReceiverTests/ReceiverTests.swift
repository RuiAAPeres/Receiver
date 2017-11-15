import XCTest
@testable import Receiver

class ReceiverTests: XCTestCase {

    func test_OneListener() {
        let (transmitter, receiver) = Receiver<Int>.make()
        var called = 0

        receiver.listen { wave in
            XCTAssertTrue(wave == 1)
            called = called + 1
        }

        transmitter.broadcast(1)
        XCTAssertTrue(called == 1)
    }

    func test_MultipleListeners() {
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

    func test_Multithread_Fun() {
        let expect = expectation(description: "fun")
        let (transmitter, receiver) = Receiver<Int>.make()
        var called = 0

        let oneQueue = DispatchQueue(label: "oneQueue")
        let twoQueues = DispatchQueue(label: "twoQueues")
        let threeQueues = DispatchQueue(label: "threeQueues")
        let fourQueues = DispatchQueue(label: "fourQueues")

        for _ in 1...5 {
            receiver.listen { wave in
                called = called + 1
            }
        }

        for _ in 1...100 {
            oneQueue.async {
                transmitter.broadcast(1)
            }
            twoQueues.async {
                transmitter.broadcast(2)
            }
            threeQueues.async {
                transmitter.broadcast(3)
            }
            fourQueues.async {
                transmitter.broadcast(4)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            XCTAssert(called == 2000)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_SendLastValue() {
        let (transmitter, receiver) = Receiver<Int>.make(with: .sendLastValue)
        transmitter.broadcast(1)

        receiver.listen { wave in
            XCTAssertTrue(wave == 1)
        }
    }
}
