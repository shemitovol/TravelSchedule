import OpenAPIRuntime
import OpenAPIURLSession

typealias StationSchedule = Components.Schemas.ScheduleResponse

protocol StationScheduleServiceProtocol {
    func getStationSchedule(station: String) async throws -> StationSchedule
}

final class StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getStationSchedule(station: String) async throws -> StationSchedule {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apikey,
            station: station
        ))
        return try response.ok.body.json
    }
}

private let testStation = "s9600213"
func testFetchStationSchedule() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let configuration = AuthConfiguration.standard
            let service = StationScheduleService(
                client: client,
                apikey: configuration.apiKey
            )
            print("Fetching station schedule...")
            let stationSchedule = try await service.getStationSchedule(station: testStation)
            print("Successfully fetched station schedule: \(stationSchedule)")
        } catch {
            print("Error fetching station schedule: \(error)")
        }
    }
}

