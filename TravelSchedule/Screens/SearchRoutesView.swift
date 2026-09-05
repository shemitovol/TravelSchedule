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

    private var filtersAreActive: Bool {
        !selectedTime.isEmpty || selectedTransfers != nil
    }

    init(
        service: ScheduleBetweenStationsServiceProtocol,
        carrierInfoService: CarrierInfoServiceProtocol,
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
                service: service,
                carrierInfoService: carrierInfoService
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
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(16)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.error {
                NetworkErrorView(
                    errorType: error == .network ? .network : .server
                )
            } else if filteredRoutes.isEmpty {
                emptyState
            } else {
                routesContent
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
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
    }

    // MARK: - Routes Content

    private var routesContent: some View {

        ZStack(alignment: .bottom) {
            List(filteredRoutes) { route in
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
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .safeAreaInset(edge: .bottom) {
                Button(action: specifyTime) {
                    HStack(spacing: 8) {
                        Text("Уточнить время")
                            .font(.bold17)
                            .foregroundStyle(Color.ypWhiteDay)

                        if filtersAreActive {
                            Circle()
                                .fill(Color.ypRed)
                                .frame( width: 8, height: 8)
                        }
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                }
                .frame( maxWidth: .infinity, maxHeight: 60)
                .background(Color.ypBlue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Filtered Routes

    private var filteredRoutes:
        [SearchRoutesViewModel.Route] {

        viewModel.routes.filter { route in
            let transferMatches: Bool
            switch selectedTransfers {
            case .withTransfers:
                transferMatches = true
            case .withoutTransfers:
                transferMatches = !route.isTransfer
            case nil:
                transferMatches = true
            }

            let timeMatches: Bool
            if selectedTime.isEmpty {
                timeMatches = true
            } else {
                timeMatches = selectedTime.contains {
                    $0.contains(route.departure)
                }
            }

            return transferMatches && timeMatches
        }
    }

    // MARK: - Route Card

    private func routeCard(
        _ route: SearchRoutesViewModel.Route
    ) -> some View {
        VStack(spacing: 0) {
            HStack (alignment: .top){

                carrierLogo(for: route)
                    .frame(
                        width: 38,
                        height: 38
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .clipped()

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    if let carrierTitle = route.carrierTitle,
                       !carrierTitle.isEmpty {

                        Text(carrierTitle)
                            .font(.regular17)
                            .foregroundStyle(
                                Color.ypBlackDay
                            )
                    }

                    if route.isTransfer {
                        Text(route.transferStation.map {
                            "С пересадкой в \($0)"
                        } ?? "С пересадкой"
                        )
                        .font(.regular12)
                        .foregroundStyle(
                            Color.ypRed
                        )
                    }
                }

                Spacer()

                Text(formatDate(route.arrival))
                    .font(.regular12)
                    .foregroundStyle(
                        Color.ypBlackDay
                    )
                    .padding(.trailing, -8)
                    .frame(alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            Spacer(minLength: 0)

            HStack(spacing: 8) {

                Text(formatTime(route.departure))
                    .font(.regular17)
                    .foregroundStyle(
                        Color.ypBlackDay
                    )
                    .frame(
                        minWidth: 48,
                        alignment: .leading
                    )

                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                Text(
                    formatDuration(
                        route.totalDuration
                    )
                )
                .font(.regular12)
                .foregroundStyle(
                    Color.ypBlackDay
                )
                .fixedSize()

                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                Text(formatTime(route.arrival))
                    .font(.regular17)
                    .foregroundStyle(
                        Color.ypBlackDay
                    )
                    .frame(
                        minWidth: 48,
                        alignment: .trailing
                    )
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
                        .foregroundStyle(
                            Color.ypWhiteDay
                        )

                    if filtersAreActive {
                        Circle()
                            .fill(Color.ypRed)
                            .frame(
                                width: 8,
                                height: 8
                            )
                    }
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

    // MARK: - Time

    private func formatTime(
        _ dateString: String
    ) -> String {
        guard let timeStart = dateString.firstIndex(
            of: "T"
        ) else {
            return dateString
        }

        let time = dateString[
            dateString.index(after: timeStart)...
        ]

        return String(time.prefix(5))
    }

    // MARK: - Date

    private func formatDate(
        _ dateString: String
    ) -> String {

        guard let date = ISO8601DateFormatter()
            .date(from: dateString)
        else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"

        return formatter.string(from: date)
    }

    // MARK: - Duration

    private func formatDuration(
        _ seconds: Int?
    ) -> String {

        guard let seconds else {
            return ""
        }

        let hours = seconds / 3600

        let word: String

        if hours % 100 >= 11 &&
            hours % 100 <= 14 {

            word = "часов"

        } else {

            switch hours % 10 {
            case 1:
                word = "час"
            case 2...4:
                word = "часа"
            default:
                word = "часов"
            }
        }

        return "\(hours) \(word)"
    }
}

