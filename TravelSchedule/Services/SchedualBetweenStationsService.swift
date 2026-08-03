//
//  SchedualBetweenStationsService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.08.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias SchedualBetweenStations = Components.Schemas.Segments

protocol SchedualBetweenStationsServiceProtocol {
    func getSchedualBetweenStations(from: String, to: String) async throws -> SchedualBetweenStations
}

final class SchedualBetweenStationsService: BaseService, SchedualBetweenStationsServiceProtocol {
    func getSchedualBetweenStations(from: String, to: String) async throws -> SchedualBetweenStations {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to
        ))
        return try response.ok.body.json
    }
}
