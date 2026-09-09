//
//  NetworkClientProtocol.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 09.09.2026.
//

protocol NetworkClientProtocol: Sendable {
    func getAllStations() async throws -> AllStations
    func getCarrierInfo(code: String) async throws -> CarrierInfo
    func getCopyright() async throws -> Copyright
    func getNearestCity(lat: Double, lng: Double) async throws -> NearestCity
    func getNearestStations(lat: Double,lng: Double, distance: Int) async throws -> NearestStations
    func getRouteStations(uid: String) async throws -> RouteStations
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String,
        transfers: Bool
    ) async throws -> ScheduleBetweenStations
    func getStationSchedule( station: String) async throws -> StationSchedule
}
