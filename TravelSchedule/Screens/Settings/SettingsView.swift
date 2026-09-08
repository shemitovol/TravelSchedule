//
//  SettingsView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 25.08.2026.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @State private var viewModel: SettingsViewModel

    init(isDarkMode: Binding<Bool>, onUserAgreement: @escaping () -> Void) {
        self._isDarkMode = isDarkMode
        self._viewModel = State(
            initialValue: SettingsViewModel(
                onUserAgreement: onUserAgreement
            )
        )
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text(viewModel.darkModeString)
                        .foregroundStyle(Color.ypBlack)
                        .font(.regular17)
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                        .tint(Color.ypBlue)
                }
                .frame(height: 60)
                .padding(.horizontal, 16)

                Button {
                    viewModel.onUserAgreement()
                } label: {
                    HStack {
                        Text(viewModel.userAgreement)
                            .foregroundStyle(Color.ypBlack)
                            .font(.regular17)
                        Spacer()
                        Image(.chevron)
                            .foregroundStyle(Color.ypBlack)
                            .frame(width: 24, height: 24)
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                Text(viewModel.apiDescription)
                Text(viewModel.appVersion)
            }
            .font(.regular12)
            .foregroundStyle(Color.ypBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 24)
        .background(Color.ypWhite)

    }
}
