//
//  StationSelectionView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 26.08.2026.
//

import SwiftUI

struct StationSelectionView: View {
    @State private var viewModel: StationSelectionViewModel
    @Environment(\.dismiss) private var dismiss

    let onSelect: (Components.Schemas.Station) -> Void

    init(
        city: Components.Schemas.Settlement,
        onSelect: @escaping (Components.Schemas.Station) -> Void
    ) {
        _viewModel = State(
            wrappedValue: StationSelectionViewModel(
                stations: city.stations ?? []
            )
        )
        self.onSelect = onSelect
    }

    var body: some View {
        VStack {
            SearchBarView(searchText: $viewModel.searchString)

            if viewModel.searchResults.isEmpty && !viewModel.searchString.isEmpty {
                Text("Станция не найдена")
                    .foregroundStyle(Color.ypBlack)
                    .font(.bold24)
            } else {
                List(viewModel.searchResults, id: \.self) { station in
                    Button {
                        onSelect(station)
                    } label: {
                        HStack {
                            Text(station.title ?? "")
                                .foregroundStyle(Color.ypBlack)
                                .font(.regular17)
                            Spacer()
                            Image(.chevron)
                                .foregroundStyle(Color.ypBlack)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 60)
                        .background(Color.ypWhite)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .padding(0)
                .scrollContentBackground(.hidden)
                .background(Color.ypWhite)
            }
        }
        .navigationTitle("Выбор станции")
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button {
                    dismiss()
                } label: {
                    Image(.chevron)
                        .scaleEffect(x: -1, y: 1)
                        .foregroundStyle(Color.ypBlack)
                }
                .padding(.leading, -16)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ypWhite)
    }
}

