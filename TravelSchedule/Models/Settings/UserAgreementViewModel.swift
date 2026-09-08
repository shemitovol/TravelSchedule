//
//  UserAgreementViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 08.09.2026.
//

import Observation
import Foundation

@MainActor
@Observable
final class UserAgreementViewModel {
    let urlString = "https://yandex.ru/legal/practicum_offer"

    var isLoading = true
    var hasError = false

    var url: URL? {
        URL(string: urlString)
    }

    func retry() {
        isLoading = true
        hasError = false
    }
}
