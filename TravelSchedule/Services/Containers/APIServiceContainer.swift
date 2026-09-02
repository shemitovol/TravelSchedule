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
    let scheduleBetweenStationsService: ScheduleBetweenStationsServiceProtocol
    let carrierInfoService: CarrierInfoServiceProtocol

    init() throws {
        let client = Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport()
        )

        let configuration = AuthConfiguration.standard

        self.allStationsService = AllStationsService(
            client: client,
            apikey: configuration.apiKey
        )
        self.scheduleBetweenStationsService = ScheduleBetweenStationsService(
            client: client,
            apikey: configuration.apiKey
        )
        self.carrierInfoService = CarrierInfoService(
            client: client,
            apikey: configuration.apiKey
        )
    }
}
