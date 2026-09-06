//
//  TravelScheduleApp.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 18.07.2026.
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    @State private var isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    @Environment(\.colorScheme) private var colorSheme

    var body: some Scene {
        WindowGroup {
            RootView(isDarkMode: $isDarkMode)
        }
    }
}
