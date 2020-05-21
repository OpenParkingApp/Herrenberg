import Foundation
import Datasource

enum ParkAPI {
    private struct Response: Decodable {
        let dataSource: URL
        let lastDownloaded: Date
        let lastUpdated: Date
        let lots: [Response.Lot]

        struct Lot: Decodable {
            let lotType: LotType
            let address: String
            let name: String
            let forecast: Bool
            let state: State
            let coords: Coords
            let url: URL?
            let total: Int
            let free: Int?
            let openingHours: String?
            let fees: String?

            enum LotType: String, Decodable {
                case parkplatz = "Parkplatz"
                case parkhaus = "Parkhaus"
                case tiefgarage = "Tiefgarage"
                case parkAndRide = "Park-Ride"
                case camper = "Wohnmobilparkplatz"
                case carpool = "Park-Carpool"

                var opRepr: Datasource.Lot.LotType {
                    switch self {
                    case .parkplatz:
                        return .lot
                    case .parkhaus:
                        return .structure
                    case .tiefgarage:
                        return .underground
                    default:
                        // TODO: Not sure about carpool, but parkAndRide and camper could make sense to be moved into OpenParkingBase.
                        return .lot
                    }
                }
            }

            enum State: String, Decodable {
                case open, closed, nodata, unknown

                var opRepr: Datasource.Lot.State {
                    switch self {
                    case .open:
                        return .open
                    case .closed:
                        return .closed
                    default:
                        return .noData
                    }
                }
            }

            struct Coords: Decodable {
                let lat: Double
                let lng: Double
            }
        }
    }

    static func read(data: Data) throws -> DataPoint {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Berlin")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let response = try decoder.decode(Response.self, from: data)

        return DataPoint(timestamp: response.lastDownloaded, lots: response.lots.compactMap {
            guard let freeCount = $0.free else {
                warn("No count of free lots available, dropping this datapoint.", lotName: $0.name)
                return nil
            }

            return .success(Lot(dataAge: response.lastUpdated,
                name: $0.name,
                coordinates: .init(lat: $0.coords.lat, lng: $0.coords.lng),
                city: "Herrenberg",
                region: nil,
                address: $0.address,
                available: .discrete(freeCount),
                capacity: $0.total,
                state: $0.state.opRepr,
                type: $0.lotType.opRepr,
                detailURL: $0.url,
                imageURL: nil,
                pricing: $0.fees.map { Lot.Pricing.info($0) },
                openingHours: $0.openingHours.map { Lot.OpeningHours.info($0) },
                additionalInformation: nil)
            )
        })
    }
}
