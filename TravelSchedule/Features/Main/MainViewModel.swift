//
//  MainViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 08.09.2026.
//

import Observation

@MainActor
@Observable
final class MainViewModel {
    var fromStation = ""
    var fromStationCode = ""
    var toStation = ""
    var toStationCode = ""

    var selectedTime: Set<DepartureTimeFilter> = []
    var selectedTransfers: TransferFilter?

    var viewedStories: Set<Int> = []

    var sortedStoryIndices: [Int] {
        Story.stories.indices.sorted {
            !viewedStories.contains($0) && viewedStories.contains($1)
        }
    }

    func selectiFromStation(_ title: String?, code: String?) {
        fromStation = title ?? ""
        fromStationCode = code ?? ""
    }

    func selectToStation(_ title: String?, code: String?) {
        toStation = title ?? ""
        toStationCode = code ?? ""
    }

    func swapStations() {
        swap(&fromStation, &toStation)
        swap(&fromStationCode, &toStationCode)
    }
}
