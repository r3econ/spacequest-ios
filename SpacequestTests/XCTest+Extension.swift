import XCTest

/**
 Extension for `XCTestCase` to allow for simple `XCTPass` statements
 */
extension XCTestCase {

    /**
     Equivalent to calling `XCTAssertTrue(true)`
     */
    func XCTPass(_ message: String = "") {
        XCTAssertTrue(true, message)
    }

}
