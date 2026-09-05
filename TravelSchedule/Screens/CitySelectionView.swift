//
//  CitySelectionView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 25.08.2026.
//

import SwiftUI

struct CitySelectionView: View {
    @State private var viewModel: CitySelectionViewModel
    @State private var searchString = ""
    @State private var selectedCity: Components.Schemas.Settlement?

    @Environment(\.dismiss) private var dismiss

    let onSelect: (
        Components.Schemas.Settlement,
        Components.Schemas.Station
    ) -> Void

    init(
        service: AllStationsServiceProtocol,
        onSelect: @escaping (
            Components.Schemas.Settlement,
            Components.Schemas.Station
        ) -> Void
    ) {
        _viewModel = State(
            wrappedValue: CitySelectionViewModel(service: service)
        )
        self.onSelect = onSelect
    }

    private var searchResults: [Components.Schemas.Settlement] {
        viewModel.cities.filter {
            searchString.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchString) == true
        }
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                NetworkErrorView(
                    errorType: error == .network ? .network : .server
                )
            } else {
                SearchBarView(searchText: $searchString)

                if searchResults.isEmpty && !searchString.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    cityList
                }
            }
        }
        .navigationTitle("Выбор города")
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $selectedCity) { city in
            StationSelectionView(city: city) { station in
                onSelect(city, station)
            }
        }
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
        .task {
            await viewModel.loadCities()
        }
    }

    private var emptyState: some View {
        Text("Город не найден")
            .foregroundStyle(Color.ypBlack)
            .font(.bold24)
    }

    private var cityList: some View {
        List(searchResults, id: \.self) { city in
            Button {
                selectedCity = city
            } label: {
                HStack {
                    Text(city.title ?? "")
                        .foregroundStyle(Color.ypBlack)
                        .font(.regular17)

                    Spacer()

                    Image(.chevron)
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 16)
                .frame(height: 60)
                .background(Color.ypWhite)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.ypWhite)
    }
}
