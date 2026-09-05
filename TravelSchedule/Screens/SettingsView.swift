//
//  SettingsView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 25.08.2026.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Environment(\.colorScheme) private var colorSheme
    let onUserAgreement: () -> Void

    var body: some View {
        VStack {
            VStack (spacing: 0) {
                HStack {
                    Text("Темная тема")
                        .foregroundStyle(Color.ypBlack)
                        .font(.regular17)
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                        .tint(Color.ypBlue)
                }
                .frame(height: 60)
                .padding(.horizontal, 16)

                Button {
                    onUserAgreement()
                } label: {
                    HStack {
                        Text("Пользовательское соглашение")
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

            VStack (spacing: 16) {
                Text("Приложение использует API «Яндекс.Расписания»")
                Text("Версия 1.0 (beta)")
            }
            .font(.regular12)
            .foregroundStyle(Color.ypBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 24)
        .background(Color.ypWhite)

    }
}
