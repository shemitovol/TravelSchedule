//
//  RootView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 02.09.2026.
//

import SwiftUI

struct RootView: View {
    @State private var apiServices: APIServiceContainer?
    @State private var error: AppError?

    var body: some View {
        Group {
            if let apiServices {
                MainView(apiServices: apiServices)
            } else if let error {
                NetworkErrorView(
                    errorType: error == .network ? .network : .server
                )
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                apiServices = try APIServiceContainer()
            } catch {
                self.error = .server
            }
        }
    }
}
