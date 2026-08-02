import OpenAPIRuntime
import OpenAPIURLSession

typealias SchedualBetweenStations = Components.Schemas.Segments

protocol SchedualBetweenStationsServiceProtocol {
    func getSchedualBetweenStations(from: String, to: String) async throws -> SchedualBetweenStations
}

final class SchedualBetweenStationsService: SchedualBetweenStationsServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getSchedualBetweenStations(from: String, to: String) async throws -> SchedualBetweenStations {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to
        ))
        return try response.ok.body.json
    }
}

private let testStation = "s9600213"
private let testCity = "c146"
func testFetchScheduleBetweenStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let configuration = AuthConfiguration.standard
            let service = SchedualBetweenStationsService(
                client: client,
                apikey: configuration.apiKey
            )
            print("Fetching schedule between stations...")
            let scheduleBetweenStations = try await service.getSchedualBetweenStations(
                    from: testStation,
                    to: testCity
                )
            print("Successfully fetched schedule between stations: \(scheduleBetweenStations)")
        } catch {
            print("Error fetching schedule between stations: \(error)")
        }
    }
}
