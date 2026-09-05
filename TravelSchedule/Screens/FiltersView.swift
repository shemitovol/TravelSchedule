//
//  SpecifyTimeView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 30.08.2026.
//

import SwiftUI

enum DepartureTimeFilter: String, CaseIterable, Identifiable {
    case morning
    case day
    case evening
    case night

    var id: Self {self}

    var title: String {
        switch self {
        case .morning:
            "Утро 06:00 - 12:00"
        case .day:
            "День 12:00 - 18:00"
        case .evening:
            "Вечер 18:00 - 00:00"
        case .night:
            "Ночь 00:00 - 06:00"
        }
    }

    func contains(_ dateString: String) -> Bool {
        guard
            let timeStart = dateString.firstIndex(of: "T")
        else {
            return false
        }

        let time = dateString[
            dateString.index(after: timeStart)...
        ]

        guard
            let hour = Int(time.prefix(2))
        else {
            return false
        }

        switch self {
        case .morning:
            return hour >= 6 && hour < 12

        case .day:
            return hour >= 12 && hour < 18

        case .evening:
            return hour >= 18 && hour < 24

        case .night:
            return hour >= 0 && hour < 6
        }
    }
}

enum TransferFilter: String, CaseIterable, Identifiable {
    case withTransfers
    case withoutTransfers

    var id: Self { self }

    var title: String {
        switch self {
        case .withTransfers:
            "Да"
        case .withoutTransfers:
            "Нет"
        }
    }
}


struct FiltersView: View {
    @Binding var selectedTime: Set<DepartureTimeFilter>
    @Binding var selectedTransfers: TransferFilter?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Text("Время отправления")
                .foregroundStyle(Color.ypBlack)
                .font(.bold24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

            ForEach(DepartureTimeFilter.allCases) { filter in
                Button {
                    if selectedTime.contains(filter) {
                        selectedTime.remove(filter)
                    } else {
                        selectedTime.insert(filter)
                    }
                } label: {
                    HStack {
                        Text(filter.title)
                            .foregroundStyle(Color.ypBlack)
                            .font(.regular17)
                        Spacer()
                        Image(
                            selectedTime.contains(filter) ? .checkBoxOn : .checkBoxOff
                        )
                            .foregroundStyle(Color.ypBlack)
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                }
            }

            Text("Показывать варианты с пересадками")
                .foregroundStyle(Color.ypBlack)
                .font(.bold24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

            ForEach(TransferFilter.allCases) { filter in
                Button {
                    selectedTransfers = filter
                } label: {
                    HStack {
                        Text(filter.title)
                            .foregroundStyle(Color.ypBlack)
                            .font(.regular17)
                        Spacer()
                        Image(selectedTransfers == filter ? .radioButtonOn : .radioButtonOff)
                            .foregroundStyle(Color.ypBlack)
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                }
            }

            Spacer()

            Button(action: applyFilters) {
                Text("Применить")
                    .font(.bold17)
                    .foregroundStyle(Color.ypWhiteDay)
                    .frame(maxWidth: .infinity, maxHeight: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(Color.ypBlue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.ypWhite)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button {
                    dismiss()
                } label: {
                    Image(.chevron)
                        .scaleEffect(x: -1, y: 1)
                }
                .padding(.leading, -16)
        )
    }

    private func applyFilters() {
        dismiss()
    }
}

