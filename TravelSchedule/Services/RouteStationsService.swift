import OpenAPIRuntime
import OpenAPIURLSession

typealias RouteStations = Components.Schemas.ThreadStationsResponse

protocol RouteStationsServiceProtocol {
    func getRouteStations(uid: String) async throws -> RouteStations
}

final class RouteStationsService: RouteStationsServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getRouteStations(uid: String) async throws -> RouteStations {
        let response = try await client.getRouteStations(query: .init(
            apikey: apikey,
            uid: uid
        ))
        return try response.ok.body.json
    }
}

private let testUid = "SU-1942_260802_c26_12"
func testFetchRouteStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let configuration = AuthConfiguration.standard
            let service = RouteStationsService(
                client: client,
                apikey: configuration.apiKey
            )
            print("Fetching route stations...")
            let routeStations = try await service.getRouteStations(uid: testUid)
            print("Successfully fetched route stations: \(routeStations)")
        } catch {
            print("Error fetching route stations: \(error)")
        }
    }
}
