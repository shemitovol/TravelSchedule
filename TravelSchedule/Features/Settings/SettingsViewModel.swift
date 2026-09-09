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
    let appVersion = "Версия 1.0 (beta"
    let apiDescription = "Приложение использует API «Яндекс.Расписания»"
    let userAgreement = "Пользовательское соглашение"
    let darkModeString = "Темная тема"
    let onUserAgreement: () -> Void

    init(onUserAgreement: @escaping () -> Void) {
        self.onUserAgreement = onUserAgreement
    }
}
