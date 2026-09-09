//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 18.07.2026.
//

import SwiftUI

struct MainView: View {
    @Binding var isDarkMode: Bool
    @State private var viewModel = MainViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var selectedStoryIndex: Int?

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

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .ypBlackDay.withAlphaComponent(0.3)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
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

                if let index = selectedStoryIndex {
                    StoriesView(
                        initialIndex: index,
                        onClose: {
                            viewModel.viewedStories.insert(index)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedStoryIndex = nil
                            }
                        },
                        onStoryViewed: { index in
                            viewModel.viewedStories.insert(index)
                        }
                    )
                }
            }
            .navigationDestination(for: Route.self) { route in
                citySelectionView(for: route)
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 16) {
            storiesPreview

            routeSelectionView

            findButton
                .opacity(viewModel.fromStation.isEmpty || viewModel.toStation.isEmpty ? 0 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .background(Color.ypWhite)
    }

    private var storiesPreview: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(viewModel.sortedStoryIndices, id: \.self) { index in
                    StoryView(story: Story.stories[index], isPreview: true)
                        .opacity(viewModel.viewedStories.contains(index) ? 0.5 : 1)
                        .overlay {
                            if !viewModel.viewedStories.contains(index) && selectedStoryIndex != index {
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.ypBlue, lineWidth: 4)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedStoryIndex = index
                            }
                        }
                }
            }
            .padding(.vertical, 24)
        }
        .scrollIndicators(.never)
    }

    private var routeSelectionView: some View {
        VStack {
            HStack(spacing: 16) {
                VStack(spacing: 0) {
                    fromCityButton
                    toCityButton
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Button(action: viewModel.swapStations) {
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
        .padding(.top, 20)
    }

    private var fromCityButton: some View {
        NavigationLink(value: Route.fromCity) {
            routeText(
                placeholder: "Откуда",
                station: viewModel.fromStation
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(Color.ypWhiteDay)
        .font(.regular17)
    }

    private var toCityButton: some View {
        NavigationLink(value: Route.toCity) {
            routeText(
                placeholder: "Куда",
                station: viewModel.toStation
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(Color.ypWhiteDay)
        .font(.regular17)
    }

    private func routeText(
        placeholder: String,
        station: String
    ) -> some View {

        Text(station.isEmpty ? placeholder : station)
            .foregroundStyle( station.isEmpty ? Color.ypGray : Color.ypBlackDay)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .lineLimit(1)
    }

    private var findButton: some View {
        Button {
            navigationPath.append(Route.results)
        } label: {
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
                networkClient: apiServices.networkClient
            ) { _, station in
                viewModel.selectiFromStation(station.title, code: station.codes?.yandex_code)
                navigationPath = NavigationPath()
            }

        case .toCity:
            CitySelectionView(
                networkClient: apiServices.networkClient
            ) { _, station in
                viewModel.selectToStation(station.title, code: station.codes?.yandex_code)
                navigationPath = NavigationPath()
            }

        case .results:
            SearchRoutesView(
                networkClient: apiServices.networkClient,
                fromStation: viewModel.fromStation,
                toStation: viewModel.toStation,
                fromStationCode: viewModel.fromStationCode,
                toStationCode: viewModel.toStationCode,
                selectedTime: viewModel.selectedTime,
                selectedTransfers: viewModel.selectedTransfers,
                onShowFilters: {
                    navigationPath.append(Route.filters)
                },
                onShowCarrier: { route in
                    navigationPath.append(Route.carrier(route))
                }
            )
        case .filters:
            FiltersView(
                selectedTime: $viewModel.selectedTime,
                selectedTransfers: $viewModel.selectedTransfers
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
}

