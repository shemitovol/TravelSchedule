//
//  StationSelectionViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 08.09.2026.
//

import Observation
import Foundation

@MainActor
@Observable
final class StationSelectionViewModel {
    let stations: [Components.Schemas.Station]
    var searchString = ""

    init(stations: [Components.Schemas.Station]) {
        self.stations = stations
    }

    var searchResults: [Components.Schemas.Station] {
        stations.filter {
            searchString.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchString) == true
        }
    }
}
