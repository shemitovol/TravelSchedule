//
//  APIServiceContainer.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 26.08.2026.
//

import Foundation

final class APIServiceContainer {
    let networkClient: NetworkClientProtocol

    init() throws { self.networkClient = try NetworkClient() }
}
