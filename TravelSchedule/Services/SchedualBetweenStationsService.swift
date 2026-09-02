//
//  ScheduleBetweenStationsService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.08.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias ScheduleBetweenStations = Components.Schemas.Segments

protocol ScheduleBetweenStationsServiceProtocol {
    func getScheduleBetweenStations(from: String, to: String, date: String, transfers: Bool) async throws -> ScheduleBetweenStations
}

final class ScheduleBetweenStationsService: BaseService, ScheduleBetweenStationsServiceProtocol {
    func getScheduleBetweenStations(from: String, to: String, date: String, transfers: Bool) async throws -> ScheduleBetweenStations {
        do {
            let response = try await client.getScheduleBetweenStations(query: .init(
                apikey: apikey,
                from: from,
                to: to,
                date: date,
                transfers: transfers
            ))
            return try response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }
}
