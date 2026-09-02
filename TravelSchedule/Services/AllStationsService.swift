//
//  AllStationsService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.08.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStations = Components.Schemas.AllStationsResponse

protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: BaseService, AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations {
        do {
            let response = try await client.getAllStations(query: .init(apikey: apikey))
            let responseBody = try response.ok.body.html
            let limit = 50 * 1024 * 1024
            let fullData = try await Data(collecting: responseBody, upTo: limit)
            let allStations = try JSONDecoder().decode(AllStations.self, from: fullData)
            return allStations
        } catch {
            throw handleError(error)
        }
    }
}
