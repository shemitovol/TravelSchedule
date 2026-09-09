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

    enum State {
        case loading
        case loaded
        case error
    }

    var state: State = .loading

    var url: URL? {
        URL(string: urlString)
    }

    func retry() {
        state = .loading
    }
}
