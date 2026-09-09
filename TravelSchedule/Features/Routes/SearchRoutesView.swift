//
//  SearchRoutesView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 28.08.2026.
//

import SwiftUI

struct SearchRoutesView: View {
    @State private var viewModel: SearchRoutesViewModel

    @Environment(\.dismiss) private var dismiss

    let fromStation: String
    let toStation: String
    let fromStationCode: String
    let toStationCode: String

    let selectedTime: Set<DepartureTimeFilter>
    let selectedTransfers: TransferFilter?

    let onShowFilters: () -> Void
    let onShowCarrier: (SearchRoutesViewModel.Route) -> Void

    init(
        networkClient: NetworkClientProtocol,
        fromStation: String,
        toStation: String,
        fromStationCode: String,
        toStationCode: String,
        selectedTime: Set<DepartureTimeFilter>,
        selectedTransfers: TransferFilter?,
        onShowFilters: @escaping () -> Void,
        onShowCarrier: @escaping (SearchRoutesViewModel.Route) -> Void
    ) {
        _viewModel = State(
            wrappedValue: SearchRoutesViewModel(
                networkClient: networkClient,
                selectedTime: selectedTime,
                selectedTransfers: selectedTransfers
            )
        )

        self.fromStation = fromStation
        self.toStation = toStation
        self.fromStationCode = fromStationCode
        self.toStationCode = toStationCode
        self.selectedTime = selectedTime
        self.selectedTransfers = selectedTransfers
        self.onShowFilters = onShowFilters
        self.onShowCarrier = onShowCarrier
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            Text("\(fromStation) → \(toStation)")
                .foregroundStyle(Color.ypBlack)
                .font(.bold24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)

            switch viewModel.state {
            case .idle, .loading:
                Spacer()
                ProgressView()
                Spacer()
            case .loaded:
                if viewModel.filteredRoutes.isEmpty{
                    emptyState
                } else {
                    routesContent
                }
            case .error(let error):
                NetworkErrorView(
                    errorType: error == .network ? .network : .server
                )
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .background(Color.ypWhite)
        .task {
            await viewModel.search(
                from: fromStationCode,
                to: toStationCode
            )
        }
        .onChange(of: selectedTime) { _, newValue in
            viewModel.selectedTime = newValue
        }
        .onChange(of: selectedTransfers) { _, newValue in
            viewModel.selectedTransfers = newValue
        }
    }

    // MARK: - Routes Content

    private var routesContent: some View {

        ZStack(alignment: .bottom) {
            List(viewModel.filteredRoutes) { route in
                Button {
                    onShowCarrier(route)
                } label: {
                    routeCard(route)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.ypWhite)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Button(action: specifyTime) {
                    HStack(spacing: 8) {
                        Text("Уточнить время")
                            .font(.bold17)
                            .foregroundStyle(Color.ypWhiteDay)

                        Circle()
                            .fill(Color.ypRed)
                            .frame(width: 8, height: 8)
                            .opacity(viewModel.filtersAreActive ? 1 : 0)
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color.ypBlue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Route Card

    private func routeCard(
        _ route: SearchRoutesViewModel.Route
    ) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                carrierLogo(for: route)
                    .frame(width: 38, height: 38)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .clipped()

                VStack(alignment: .leading, spacing: 2) {
                    if let carrierTitle = route.carrierTitle {
                        Text(carrierTitle)
                            .font(.regular17)
                            .foregroundStyle(Color.ypBlackDay)
                            .opacity(carrierTitle.isEmpty ? 0 : 1)
                    }

                    Text(
                        route.transferStation.map { "С пересадкой в \($0)" }
                        ?? "С пересадкой"
                    )
                    .font(.regular12)
                    .foregroundStyle(Color.ypRed)
                    .opacity(route.isTransfer ? 1 : 0)
                }

                Spacer()

                Text(viewModel.formatDate(route.arrival))
                    .font(.regular12)
                    .foregroundStyle(Color.ypBlackDay)
                    .padding(.trailing, -8)
                    .frame(alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            Spacer(minLength: 0)

            HStack(spacing: 8) {

                Text(viewModel.formatTime(route.departure))
                    .font(.regular17)
                    .foregroundStyle( Color.ypBlackDay)
                    .frame(minWidth: 48, alignment: .leading)

                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                Text(viewModel.formatDuration(route.totalDuration))
                    .font(.regular12)
                    .foregroundStyle(Color.ypBlackDay)
                    .fixedSize()

                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                Text(viewModel.formatTime(route.arrival))
                    .font(.regular17)
                    .foregroundStyle(Color.ypBlackDay)
                    .frame(minWidth: 48, alignment: .trailing)
            }
            .padding([.horizontal, .bottom], 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .background(Color.ypLightGray)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Carrier Logo

    @ViewBuilder
    private func carrierLogo(
        for route: SearchRoutesViewModel.Route
    ) -> some View {

        if let logo = route.carrierLogo,
           !logo.isEmpty,
           let url = URL(string: logo) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    logoChecker

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    logoChecker

                @unknown default:
                    logoChecker
                }
            }

        } else {
            logoChecker
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()

            Text("Вариантов нет")
                .foregroundStyle(Color.ypBlack)
                .font(.bold24)

            Spacer()

            Button(action: specifyTime) {
                HStack(spacing: 8) {
                    Text("Уточнить время")
                        .font(.bold17)
                        .foregroundStyle(Color.ypWhiteDay)

                    Circle()
                        .fill(Color.ypRed)
                        .frame(width: 8, height: 8)
                        .opacity(viewModel.filtersAreActive ? 1 : 0)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }
            .background(Color.ypBlue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Logo Placeholder

    private var logoChecker: some View {
        Image(.logoChecker)
            .resizable()
            .scaledToFit()
    }

    // MARK: - Actions

    private func specifyTime() {
        onShowFilters()
    }
}

