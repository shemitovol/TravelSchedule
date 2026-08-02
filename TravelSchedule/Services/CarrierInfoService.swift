import OpenAPIRuntime
import OpenAPIURLSession

typealias CarrierInfo = Components.Schemas.CarrierResponse

protocol CarrierInfoServiceProtocol {
    func getCarrierInfo(code: String) async throws -> CarrierInfo
}

final class CarrierInfoService: CarrierInfoServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getCarrierInfo(code: String) async throws -> CarrierInfo {
        let response = try await client.getCarrierInfo(query: .init(
            apikey: apikey,
            code: code
        ))
        return try response.ok.body.json
    }
}

private let testCode = "66067"
func testFetchCarrierInfo() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let configuration = AuthConfiguration.standard
            let service = CarrierInfoService(
                client: client,
                apikey: configuration.apiKey
            )
            print("Fetching carrier info...")
            let carrierInfo = try await service.getCarrierInfo(code: testCode)
            print("Successfully fetched carrier info: \(carrierInfo)")
        } catch {
            print("Error fetching carrier info: \(error)")
        }
    }
}
