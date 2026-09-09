//
//  NetworkClient.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 09.09.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStations = Components.Schemas.AllStationsResponse

typealias CarrierInfo = Components.Schemas.CarrierResponse
typealias Copyright = Components.Schemas.CopyrightResponse
typealias NearestCity = Components.Schemas.NearestCityResponse
typealias NearestStations = Components.Schemas.Stations
typealias RouteStations = Components.Schemas.ThreadStationsResponse
typealias ScheduleBetweenStations = Components.Schemas.Segments
typealias StationSchedule = Components.Schemas.ScheduleResponse

enum AppError: Error {
    case network
    case server
}

actor NetworkClient: NetworkClientProtocol {
    private let client: Client
    private let apikey: String

    init() throws { self.client = Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        self.apikey = AuthConfiguration.standard.apiKey
    }

    func getAllStations() async throws -> AllStations {
        do {
            let response = try await client.getAllStations(
                query: .init(apikey: apikey)
            )

            let responseBody = try await response.ok.body.html
            let limit = 50 * 1024 * 1024

            let fullData = try await Data(collecting: responseBody, upTo: limit)

            return try await Self.decodeAllStations(fullData)
        } catch {
            throw handleError(error)
        }
    }

    func getCarrierInfo(code: String) async throws -> CarrierInfo {
        do {
            let response = try await client.getCarrierInfo(
                query: .init(apikey: apikey, code: code)
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    func getCopyright() async throws -> Copyright {
        do {
            let response = try await client.getCopyright(
                query: .init(apikey: apikey)
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    func getNearestCity(lat: Double, lng: Double) async throws -> NearestCity {
        do {
            let response = try await client.getNearestCity(
                query: .init(apikey: apikey, lat: lat, lng: lng)
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
        do {
            let response = try await client.getNearestStations(
                query: .init(apikey: apikey, lat: lat, lng: lng, distance: distance)
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    func getRouteStations(uid: String) async throws -> RouteStations {
        do {
            let response = try await client.getRouteStations(
                query: .init(apikey: apikey, uid: uid)
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String,
        transfers: Bool
    ) async throws -> ScheduleBetweenStations {
        do {
            let response = try await client.getScheduleBetweenStations(
                query: .init(
                    apikey: apikey,
                    from: from,
                    to: to,
                    date: date,
                    transfers: transfers
                )
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    func getStationSchedule(station: String) async throws -> StationSchedule {
        do {
            let response = try await client.getStationSchedule(
                query: .init(apikey: apikey, station: station)
            )

            return try await response.ok.body.json
        } catch {
            throw handleError(error)
        }
    }

    private func handleError(_ error: Error) -> AppError {
        if let clientError = error as? ClientError,
           clientError.underlyingError is URLError {
            return .network
        }

        return .server
    }

    @MainActor
    private static func decodeAllStations(_ data: Data) throws -> AllStations {
        try JSONDecoder().decode(AllStations.self, from: data)
    }
}
