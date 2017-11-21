import XCTest
@testable import Receiver

class ReceiverTests_Operators: XCTestCase {
    
    func test_Map() {
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
}
