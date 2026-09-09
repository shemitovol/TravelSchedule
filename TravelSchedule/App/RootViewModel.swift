//
//  RootViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 08.09.2026.
//

import Observation

@MainActor
@Observable

final class RootViewModel {
    var apiServices: APIServiceContainer?
    var error: AppError?

    func setupServices() {
        do {
            apiServices = try APIServiceContainer()
        } catch {
            self.error = .server
        }
    }
}
