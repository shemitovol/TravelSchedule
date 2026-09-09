//
//  SettingsViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 08.09.2026.
//

import Observation

@MainActor
@Observable
final class SettingsViewModel {
    let onUserAgreement: () -> Void

    init(onUserAgreement: @escaping () -> Void) {
        self.onUserAgreement = onUserAgreement
    }
}
