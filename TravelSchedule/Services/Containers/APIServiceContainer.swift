//
//  APIServiceContainer.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 26.08.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

final class APIServiceContainer {
    let allStationsService: AllStationsServiceProtocol
    let schedualBetweenStationsService: SchedualBetweenStationsServiceProtocol
    let carrierInfoService: CarrierInfoServiceProtocol

    init() {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )

            let configuration = AuthConfiguration.standard

            self.allStationsService = AllStationsService(
                client: client,
                apikey: configuration.apiKey
            )
            self.schedualBetweenStationsService = SchedualBetweenStationsService(
                client: client,
                apikey: configuration.apiKey
            )
            self.carrierInfoService = CarrierInfoService(
                client: client,
                apikey: configuration.apiKey
            )
        } catch {
            fatalError("Не удалось создать API Client: \(error)")
        }
    }
}
