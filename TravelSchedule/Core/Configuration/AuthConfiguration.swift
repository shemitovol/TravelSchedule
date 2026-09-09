//
//  AuthConfiguration.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.08.2026.
//

import Foundation

enum Constants {
    static let apiKey = Bundle.main.object(
        forInfoDictionaryKey: "YANDEX_API_KEY"
    ) as? String ?? ""
}

struct AuthConfiguration {
    let apiKey: String

    init (apiKey: String) {
        self.apiKey = apiKey
    }

    static var standard: AuthConfiguration{
        return AuthConfiguration(apiKey: Constants.apiKey,)
    }
}

