import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStations = Components.Schemas.AllStationsResponse

protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: AllStationsServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(query: .init(apikey: apikey))
        let responseBody = try response.ok.body.html
        let limit = 50 * 1024 * 1024
        let fullData = try await Data(collecting: responseBody, upTo: limit)
        let allStations = try JSONDecoder().decode(AllStations.self, from: fullData)
        return allStations
    }
}

func testFetchAllStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let configuration = AuthConfiguration.standard
            let service = AllStationsService(
                client: client,
                apikey: configuration.apiKey
            )
            print("Fetching all stations...")
            let allStations = try await service.getAllStations()
            let countries = allStations.countries ?? []
            print("Countries: \(countries.count)")
            let regions = countries.flatMap { $0.regions ?? []}
            print("Regions: \(regions.count)")
            let settlements = regions.flatMap { $0.settlements ?? []}
            print("Settlements: \(settlements.count)")
            let stations = settlements.flatMap { $0.stations ?? []}
            print("Successfully fetched all stations: \(stations.count)")
        } catch {
            print("Error fetching all stations: \(error)")
        }
    }
}
