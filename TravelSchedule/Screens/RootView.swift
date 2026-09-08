//
//  RootView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.09.2026.
//

import SwiftUI

struct RootView: View {
    @Binding var isDarkMode: Bool

    @State private var viewModel = RootViewModel()

    var body: some View {
        Group {
            if let apiServices = viewModel.apiServices {
                MainView(apiServices: apiServices, isDarkMode: $isDarkMode)
            } else if let error = viewModel.error {
                NetworkErrorView(
                    errorType: error == .network ? .network : .server
                )
            } else {
                ProgressView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .task {
            viewModel.setupServices()
        }
    }
}
