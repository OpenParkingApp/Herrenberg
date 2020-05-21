import XCTest
import DatasourceValidation
import Herrenberg

final class OpenParkingHerrenbergTests: XCTestCase {
    func testDatasource() throws {
        validate(datasource: Herrenberg())
    }
}
