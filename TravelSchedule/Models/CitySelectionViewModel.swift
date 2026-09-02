//
//  CitySelectionViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 25.08.2026.
//

import Observation

@MainActor
@Observable
final class CitySelectionViewModel {
    var cities: [Components.Schemas.Settlement] = []
    var isLoading = false
    var error: AppError?

    private let service: AllStationsServiceProtocol

    init(service: AllStationsServiceProtocol){
        self.service = service
    }

    func loadCities() async {
        isLoading = true
        error = nil

        do {
            let response = try await service.getAllStations()
            cities = response.countries?
                .flatMap { $0.regions ?? []}
                .flatMap { $0.settlements ?? []} ?? []
        } catch let error as AppError {
            self.error = error
        } catch {
            print("Неизвестная ошибка:", error)
            self.error = .server
        }

        isLoading = false
    }
}
