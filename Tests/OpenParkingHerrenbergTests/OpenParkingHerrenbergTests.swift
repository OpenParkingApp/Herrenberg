import XCTest
import OpenParkingTests
import OpenParkingHerrenberg

final class OpenParkingHerrenbergTests: XCTestCase {
    func testDatasource() throws {
        assert(datasource: Herrenberg())
    }
}
