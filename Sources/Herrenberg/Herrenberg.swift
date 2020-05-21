import Foundation
import Datasource

public class Herrenberg: Datasource {
    public let name = "Herrenberg"
    public let slug = "herrenberg"
    public let infoURL = URL(string: "https://stadtnavi.de")!

    public init() {}

    let sourceURL = URL(string: "https://api.stadtnavi.de/parkapi.json")!

    public func data() throws -> DataPoint {
        let (data, _) = try get(url: self.sourceURL)
        return try ParkAPI.read(data: data)
    }
}
