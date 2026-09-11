import XCTest
@testable import FinanceKitPlugin

class FinanceKitTests: XCTestCase {
    func testStatusNamesAreStable() {
        // The JavaScript side matches on these exact strings.
        XCTAssertEqual(HalfwayFinanceKitStore.unavailableStatus, "unavailable")
    }
}
