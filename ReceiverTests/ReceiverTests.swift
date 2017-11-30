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

    func test_Multithread() {
        let expect = expectation(description: "fun")
        let (transmitter, receiver) = Receiver<Int>.make()
        var called = 0

        let oneQueue = DispatchQueue(label: "oneQueue")
        let twoQueues = DispatchQueue(label: "twoQueues")
        let threeQueues = DispatchQueue(label: "threeQueues")
        let fourQueues = DispatchQueue(label: "fourQueues")

        receiver.listen { wave in
            called = called + 1
        }

        receiver.listen { wave in
            called = called + 1
        }

        for _ in 1...5 {
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
            XCTAssert(called == 40)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_Warm_0() {
        runWarmBattery(expectedValues: [1, 2], upTo: 0)
    }

    func test_Warm_2_Queue1() {
        runWarmBattery(expectedValues: [1, 2], upTo: 1)
    }

    func test_Warm_2_Queue2() {
        runWarmBattery(expectedValues: [1, 2], upTo: 2)
    }

    func test_Warm_2_Queue3() {
        runWarmBattery(expectedValues: [1, 2], upTo: 3)
    }

    func test_Warm_5_Queue3() {
        runWarmBattery(expectedValues: [1, 2, 3, 4, 5], upTo: 3)
    }

    func runWarmBattery(expectedValues: [Int], upTo limit: Int) {
        let (transmitter, receiver) = Receiver<Int>.make(with: .warm(upTo: limit))
        var called = 0

        expectedValues.forEach(transmitter.broadcast)

        receiver.listen { wave in
            let index = max((expectedValues.count - limit), 0) + called
            XCTAssertTrue(expectedValues[index] == wave)
            called = called + 1
        }

        XCTAssertTrue(called == min(expectedValues.count, limit))
    }

    func test_Cold() {
        let (transmitter, receiver) = Receiver<Int>.make(with: .cold)
        var called = 0

        let expectedValues = [1, 2, 3, 4, 5]
        expectedValues.forEach(transmitter.broadcast)

        receiver.listen { wave in
            XCTAssertTrue(expectedValues[called] == wave)
            called = called + 1
        }

        XCTAssertTrue(called == 5)
    }

    func test_NoValueIsSent_IfBroadCastBeforeListenning_forHot() {
        let expect = expectation(description: "fun")
        let (transmitter, receiver) = Receiver<Int>.make()

        transmitter.broadcast(1)

        receiver.listen { wave in
            fatalError()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_weakness() {
        
        var outterTransmitter: Receiver<Int>.Transmitter?
        weak var outterReceiver: Receiver<Int>?
        
        autoreleasepool {
            let (transmitter, receiver) = Receiver<Int>.make()
            outterTransmitter = transmitter
            outterReceiver = receiver
        }
        
        XCTAssertNotNil(outterTransmitter)
        XCTAssertNotNil(outterReceiver)
    }

    func test_disposable() {
        let (transmitter, receiver) = Receiver<Int>.make()
        var called = 0

        let disposable = receiver.listen { wave in
            called = called + 1
        }

        disposable.dispose()
        transmitter.broadcast(1)
        XCTAssertTrue(called == 0)
    }

    func test_disposable_MultipleListeners() {
        let (transmitter, receiver) = Receiver<Int>.make()
        var value = 0

        let disposable1 = receiver.listen { wave in
            value = 1
        }

        disposable1.dispose()
        transmitter.broadcast(1)
        XCTAssertTrue(value == 0)

        receiver.listen { wave in
            value = 2
        }

        transmitter.broadcast(1)
        XCTAssertTrue(value == 2)
    }
}
