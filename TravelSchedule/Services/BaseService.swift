//
//  BaseService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 03.08.2026.
//
import Foundation

enum AppError: Error {
    case network
    case server
}

class BaseService {
    let client: Client
    let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func handleError(_ error: Error) -> AppError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                    .networkConnectionLost,
                    .timedOut,
                    .cannotConnectToHost,
                    .cannotFindHost:
                return .network
            default:
                return .network
            }
        }
        return .server
    }
}
