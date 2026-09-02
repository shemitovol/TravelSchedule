//
//  BaseService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 03.08.2026.
//
import Foundation
import OpenAPIRuntime

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
        if let clientError = error as? ClientError,
           clientError.underlyingError is URLError {
            return .network
        }

        return .server
    }
}
