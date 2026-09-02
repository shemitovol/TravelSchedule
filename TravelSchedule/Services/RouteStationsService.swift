//
//  RouteStationsService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.08.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias RouteStations = Components.Schemas.ThreadStationsResponse

protocol RouteStationsServiceProtocol {
    func getRouteStations(uid: String) async throws -> RouteStations
}

final class RouteStationsService: BaseService, RouteStationsServiceProtocol {
    func getRouteStations(uid: String) async throws -> RouteStations {
        do {
            let response = try await client.getRouteStations(query: .init(
                apikey: apikey,
                uid: uid
            ))
            return try response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }
}
