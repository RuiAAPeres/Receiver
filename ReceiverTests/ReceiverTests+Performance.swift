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
    
    func test_listen_and_dispose_performance() {
        self.measure {
            let numberOfListeners = 10000
            var numberOfDisposes = 0
            let (transmitter, receiver) = Receiver<Int>.make()
            var called = 0
            var disposables = [Disposable]()
            
            for i in 1...numberOfListeners {
                
                let disposable = receiver.listen { wave in
                    XCTAssertTrue(wave == 1)
                    called = called + 1
                }
                
                disposables.append(disposable)
                
                if i % 3 == 0 && disposables.count > 0 {
                    let d = disposables.remove(at: Int.random(in: 0..<disposables.count))
                    d.dispose()
                    numberOfDisposes += 1
                }
            }
            
            transmitter.broadcast(1)
            XCTAssertEqual(called, numberOfListeners-numberOfDisposes)

            transmitter.broadcast(1)
            XCTAssertEqual(called, (numberOfListeners-numberOfDisposes)*2)
        }
    }

}
