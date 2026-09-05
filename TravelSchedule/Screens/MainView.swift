//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 18.07.2026.
//

import SwiftUI

struct MainView: View {
    @Binding var isDarkMode: Bool

    @State private var fromStation = ""
    @State private var fromStationCode = ""
    @State private var toStation = ""
    @State private var toStationCode = ""
    @State private var selectedTime: Set<DepartureTimeFilter> = []
    @State private var selectedTransfers: TransferFilter?
    @State private var navigationPath = NavigationPath()


    private let apiServices: APIServiceContainer

    private enum Route: Hashable {
        case fromCity
        case toCity
        case results
        case filters
        case carrier(SearchRoutesViewModel.Route)
        case userAgreement
    }

    init(apiServices: APIServiceContainer, isDarkMode: Binding<Bool>) {
        self.apiServices = apiServices
        self._isDarkMode = isDarkMode
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView {
                mainContent
                    .tabItem {
                        Label("", image: .mainScreenTab)
                    }
                
                SettingsView(
                    isDarkMode: $isDarkMode,
                    onUserAgreement: {
                        navigationPath.append(Route.userAgreement)
                    }
                )
                .tabItem {
                    Label("", image: .settingsScreenTab)
                }
            }
            .tint(Color.ypBlack)
            .navigationDestination(for: Route.self) { route in
                citySelectionView(for: route)
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 16) {
            routeSelectionView

            if !fromStation.isEmpty && !toStation.isEmpty {
                findButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .background(Color.ypWhite)
    }

    private var routeSelectionView: some View {
        VStack {
            HStack(spacing: 16) {
                VStack(spacing: 0) {
                    fromCityButton
                    toCityButton
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Button(action: swapStations) {
                    Image(.return)
                        .frame(minWidth: 36, minHeight: 36)
                }
                .background(Color.ypWhiteDay)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .frame(minWidth: 36, minHeight: 36)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: 128)
        .background(Color.ypBlue)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var fromCityButton: some View {
        NavigationLink(value: Route.fromCity) {
            routeText(
                placeholder: "Откуда",
                station: fromStation
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .padding(.horizontal)
        .background(Color.ypWhiteDay)
        .font(.regular17)
    }

    private var toCityButton: some View {
        NavigationLink(value: Route.toCity) {
            routeText(
                placeholder: "Куда",
                station: toStation
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .padding(.horizontal)
        .background(Color.ypWhiteDay)
        .font(.regular17)
    }

    private func routeText(
        placeholder: String,
        station: String
    ) -> some View {
        Text(
            station.isEmpty
            ? placeholder
            : "\(station)"
        )
        .foregroundStyle(
            station.isEmpty
            ? Color.ypGray
            : Color.ypBlackDay
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .lineLimit(1)
    }

    private var findButton: some View {
        Button(action: find) {
            Text("Найти")
                .font(.bold17)
                .foregroundStyle(Color.ypWhiteDay)
                .frame(maxWidth: 150, maxHeight: 60)
        }
        .frame(maxWidth: 150, maxHeight: 60)
        .background(Color.ypBlue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func citySelectionView(for route: Route) -> some View {
        switch route {
        case .fromCity:
            CitySelectionView(
                service: apiServices.allStationsService
            ) { city, station in
                fromStation = station.title ?? ""
                fromStationCode = station.codes?.yandex_code ?? ""
                navigationPath = NavigationPath()
            }

        case .toCity:
            CitySelectionView(
                service: apiServices.allStationsService
            ) { city, station in
                toStation = station.title ?? ""
                toStationCode = station.codes?.yandex_code ?? ""
                navigationPath = NavigationPath()
            }

        case .results:
            SearchRoutesView(
                service: apiServices.scheduleBetweenStationsService,
                carrierInfoService: apiServices.carrierInfoService,
                fromStation: fromStation,
                toStation: toStation,
                fromStationCode: fromStationCode,
                toStationCode: toStationCode,
                selectedTime: selectedTime,
                selectedTransfers: selectedTransfers,
                onShowFilters: {
                    navigationPath.append(Route.filters)
                },
                onShowCarrier: { route in
                    navigationPath.append(Route.carrier(route))
                }
            )
        case .filters:
            FiltersView(
                selectedTime: $selectedTime,
                selectedTransfers: $selectedTransfers
            )
        case .carrier(let route):
                CarrierInformationView(
                    title: route.carrierTitle ?? "",
                    logo: route.carrierLogo,
                    email: route.carrierEmail ?? "",
                    phone: route.carrierPhone ?? ""
                )
        case .userAgreement:
            UserAgreementView()
        }
    }

    private func swapStations() {
        swap(&fromStation, &toStation)
        swap(&fromStationCode, &toStationCode)
    }

    private func find() {
        navigationPath.append(Route.results)
    }
}

