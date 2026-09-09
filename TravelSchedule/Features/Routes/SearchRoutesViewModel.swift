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
    enum State {
        case idle
        case loading
        case loaded
        case error(AppError)
    }

    var state: State = .idle
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
    
    var filtersAreActive: Bool {
        !selectedTime.isEmpty || selectedTransfers != nil
    }

    private let networkClient: NetworkClientProtocol

    //MARK: - Route Card Data Formatters
    private let isoDateFormatter = ISO8601DateFormatter()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    func formatTime(_ dateString: String) -> String {
        guard let timeStart = dateString.firstIndex(of: "T") else {
            return dateString
        }

        let time = dateString[dateString.index(after: timeStart)...]
        return String(time.prefix(5))
    }

    func formatDate(_ dateString: String) -> String {
        guard let date = isoDateFormatter.date(from: dateString) else {
            return ""
        }

        return dateFormatter.string(from: date)
    }

    func formatDuration(_ seconds: Int?) -> String {
        guard let seconds else { return "" }

        let hours = seconds / 3600
        let word: String

        if hours % 100 >= 11 && hours % 100 <= 14 {
            word = "часов"
        } else {
            switch hours % 10 {
            case 1: word = "час"
            case 2...4: word = "часа"
            default: word = "часов"
            }
        }

        return "\(hours) \(word)"
    }

    // MARK: - Route

    struct Route: Identifiable, Hashable, Sendable {
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
        state = .loading
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
            state = .loaded

        } catch let error as AppError {
            state = .error(error)
        } catch {
            print("Неизвестная ошибка:", error )
            state = .error(.server)
        }
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
