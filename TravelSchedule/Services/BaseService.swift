//
//  BaseService.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 03.08.2026.
//

class BaseService {
    let client: Client
    let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
}
