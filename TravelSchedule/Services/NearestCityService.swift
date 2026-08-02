import OpenAPIRuntime
import OpenAPIURLSession

typealias NearestCity = Components.Schemas.NearestCityResponse

protocol NearestCityServiceProtocol {
    func getNearestCity(lat: Double, lng: Double) async throws -> NearestCity
}

final class NearestCityService: NearestCityServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getNearestCity(lat: Double, lng: Double) async throws -> NearestCity {
        let response = try await client.getNearestCity(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng
        ))
        return try response.ok.body.json
    }
}

private let lat = 59.864177
private let lng = 30.319163
func testFetchNearestCity() {
    Task{
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let configuration = AuthConfiguration.standard
            let service = NearestCityService(
                client: client,
                apikey: configuration.apiKey
            )
            print("Fetching city...")
            let city = try await service.getNearestCity(
                lat: lat,
                lng: lng
            )
            print("Successfully fetched city: \(city)")
        } catch {
            print("Error fetching city: \(error)")
        }
    }
}
