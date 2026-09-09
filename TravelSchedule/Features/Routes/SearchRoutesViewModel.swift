//
//  SearchRoutesViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 27.08.2026.
//

import Observation
import Foundation

@MainActor
@Observable
final class SearchRoutesViewModel {

    var isLoading = false
    var error: AppError?
    var routes: [Route] = []
    var selectedTime: Set<DepartureTimeFilter> = []
    var selectedTransfers: TransferFilter?

    var filteredRoutes: [Route] {
        routes.filter { route in
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

    private let networkClient: NetworkClientProtocol

    // MARK: - Route

    struct Route: Identifiable, Hashable {
        let id = UUID()
        let from: String
        let to: String
        let departure: String
        let arrival: String
        let duration: Int?
        let trainNumber: String?
        let carrierTitle: String?
        let carrierLogo: String?
        let carrierEmail: String?
        let carrierPhone: String?
        let isTransfer: Bool
        let transferStation: String?

        // MARK: - Calculated Duration

        var calculatedDuration: Int? {
            guard
                let departureDate = Self.isoFormatter.date(
                    from: departure
                ),
                let arrivalDate = Self.isoFormatter.date(
                    from: arrival
                )
            else {
                return nil
            }

            return Int(
                arrivalDate.timeIntervalSince(
                    departureDate
                )
            )
        }

        var totalDuration: Int? {
            duration ?? calculatedDuration
        }

        // MARK: - Formatter

        private static let isoFormatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [
                .withInternetDateTime
            ]
            return formatter
        }()

        static func date(from string: String) -> Date? {
            isoFormatter.date(from: string)
        }
    }

    // MARK: - Init

    init(
        networkClient: NetworkClientProtocol,
        selectedTime: Set<DepartureTimeFilter>,
        selectedTransfers: TransferFilter?
    ) {
        self.networkClient = networkClient
        self.selectedTime = selectedTime
        self.selectedTransfers = selectedTransfers
    }

    // MARK: - Search

    func search(from: String, to: String) async {
        isLoading = true
        error = nil
        routes = []

        do {
            let today = Self.currentDateString()
            let response = try await networkClient.getScheduleBetweenStations(
                from: from,
                to: to,
                date: today,
                transfers: true
            )

            let segments = response.segments ?? []

            // MARK: - Routes
            var newRoutes: [Route] = []
            for segment in segments {
                let thread = segment.thread ?? segment.details?.first?.thread

                var carrierTitle = thread?.carrier?.title
                var carrierLogo = thread?.carrier?.logo
                var carrierEmail = thread?.carrier?.email
                var carrierPhone = thread?.carrier?.phone

                if carrierLogo == nil || carrierLogo?.isEmpty == true || carrierEmail == nil || carrierPhone == nil {
                    if let carrierCode = thread?.carrier?.code {
                        do {
                            let carrierInfo = try await networkClient.getCarrierInfo(
                                code: "\(carrierCode)"
                            )
                            let carrier = carrierInfo.carrier ?? carrierInfo.carriers?.first
                            carrierTitle = carrier?.title ?? carrierTitle
                            carrierLogo = carrier?.logo
                            carrierEmail = carrier?.email
                            carrierPhone = carrier?.phone
                        } catch {
                            print("Не удалось получить перевозчика \(carrierCode): \(error)")
                        }
                    }
                }
                let route = Route(
                    from: segment.from?.title ?? "",
                    to: segment.to?.title ?? "",
                    departure: segment.departure ?? "",
                    arrival: segment.arrival ?? "",
                    duration: segment.duration,
                    trainNumber: thread?.number,
                    carrierTitle: carrierTitle,
                    carrierLogo: carrierLogo,
                    carrierEmail: carrierEmail,
                    carrierPhone: carrierPhone,
                    isTransfer: segment.has_transfers ?? false,
                    transferStation: segment.transfers?.first?.title
                )

                newRoutes.append(route)
            }
            routes = newRoutes.sorted {
                guard
                    let firstArrival = Route.date(from: $0.arrival),
                    let secondArrival = Route.date(from: $1.arrival)
                else {
                    return false
                }
                return firstArrival < secondArrival
            }

        } catch let error as AppError {
            self.error = error
        } catch {
            print("Неизвестная ошибка:", error )
            self.error = .server
        }
        isLoading = false
    }

    //MARK: - Today's Date Formatter

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func currentDateString() -> String {
        dateFormatter.string(from: Date())
    }
}
