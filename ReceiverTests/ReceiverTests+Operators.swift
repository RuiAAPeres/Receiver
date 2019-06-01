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
        let newReceiver = receiver.filter { $0 % 2 == 0 }
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

    func test_skipRepeats() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.skipRepeats()
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(1)
        transmitter.broadcast(2)
        transmitter.broadcast(1)
        transmitter.broadcast(2)
        transmitter.broadcast(2)
        transmitter.broadcast(3)

        XCTAssertTrue(called == 5)
    }

    func test_withPrevious_nil() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.withPrevious()
        var called = 0
        var expected: (Int?, Int) = (0, 0)

        newReceiver.listen { wave in
            expected = wave
            called = called + 1
        }

        transmitter.broadcast(1)
        XCTAssertTrue(expected.0 == nil)
        XCTAssertTrue(expected.1 == 1)

        transmitter.broadcast(2)
        XCTAssertTrue(expected.0 == 1)
        XCTAssertTrue(expected.1 == 2)

        XCTAssertTrue(called == 2)
    }

    func test_skip() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.skip(count: 3)
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(1)
        transmitter.broadcast(1)
        XCTAssertTrue(called == 0)

        transmitter.broadcast(1)
        XCTAssertTrue(called == 1)

        transmitter.broadcast(1)
        XCTAssertTrue(called == 2)
    }

    func test_skip_zero() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.skip(count: 0)
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        XCTAssertTrue(called == 1)
    }

    func test_take() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.take(count: 2)
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(1)
        transmitter.broadcast(1)
        transmitter.broadcast(1)

        XCTAssertTrue(called == 2)
    }

    func test_take_zero() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.take(count: 0)
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(1)
        transmitter.broadcast(1)
        transmitter.broadcast(1)

        XCTAssertTrue(called == 0)
    }

    func test_skipNil() {
        let (transmitter, receiver) = Receiver<Int?>.make()
        let newReceiver = receiver.skipNil()
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(nil)
        transmitter.broadcast(1)

        XCTAssertTrue(called == 2)
    }

    func test_uniqueValues() {
        let (transmitter, receiver) = Receiver<Int>.make()
        let newReceiver = receiver.uniqueValues()
        var called = 0

        newReceiver.listen { wave in
            called = called + 1
        }

        transmitter.broadcast(1)
        transmitter.broadcast(2)
        transmitter.broadcast(1)
        transmitter.broadcast(3)
        transmitter.broadcast(1)
        transmitter.broadcast(3)
        transmitter.broadcast(2)

        XCTAssertTrue(called == 3)
    }
    
    func test_combine() {
        let (intTransmitter, intReceiver) = Receiver<Int>.make()
        let (stringTransmitter, stringReceiver) = Receiver<String>.make()
        let newReceiver = combine(intReceiver, stringReceiver)
        let expectedValues = [(1,"1"),(2,"1"),(2,"2")]
        var values = [(Int,String)]()

        newReceiver.listen { wave in
            values.append(wave)
        }
        
        intTransmitter.broadcast(1)
        stringTransmitter.broadcast("1")
        intTransmitter.broadcast(2)
        stringTransmitter.broadcast("2")
        
        XCTAssertEqual(values.map{$0.0}, expectedValues.map{$0.0})
        XCTAssertEqual(values.map{$0.1}, expectedValues.map{$0.1})

    }

}
