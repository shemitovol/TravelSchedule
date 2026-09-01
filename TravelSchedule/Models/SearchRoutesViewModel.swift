//
//  SearchRoutesViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 27.08.2026.
//

import Combine
import Foundation

@MainActor
final class SearchRoutesViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var error: AppError?
    @Published var routes: [Route] = []

    private let service: SchedualBetweenStationsServiceProtocol
    private let carrierInfoService: CarrierInfoServiceProtocol

    // MARK: - Route

    struct Route: Identifiable {
        let id = UUID()
        let from: String
        let to: String
        let departure: String
        let arrival: String
        let duration: Int?
        let trainNumber: String?
        let carrierTitle: String?
        let carrierLogo: String?
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
    }

    // MARK: - Init

    init(
        service: SchedualBetweenStationsServiceProtocol,
        carrierInfoService: CarrierInfoServiceProtocol
    ) {
        self.service = service
        self.carrierInfoService = carrierInfoService
    }

    // MARK: - Search

    func search(from: String, to: String) async {
        isLoading = true
        error = nil
        routes = []

        do {
            let today = Self.currentDateString()
            let response = try await service.getSchedualBetweenStations(
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

                if carrierLogo == nil || carrierLogo?.isEmpty == true {
                    if let carrierCode = thread?.carrier?.code {
                        do {
                            let carrierInfo = try await carrierInfoService.getCarrierInfo(
                                code: "\(carrierCode)"
                            )
                            let carrier = carrierInfo.carrier ?? carrierInfo.carriers?.first
                            carrierTitle = carrier?.title ?? carrierTitle
                            carrierLogo = carrier?.logo
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
                    isTransfer: segment.has_transfers ?? false,
                    transferStation: segment.transfers?.first?.title
                )

                newRoutes.append(route)
            }
            routes = newRoutes.sorted {
                guard
                    let firstArrival = ISO8601DateFormatter().date(
                        from: $0.arrival
                    ),
                    let secondArrival = ISO8601DateFormatter().date(
                        from: $1.arrival
                    )
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

    // MARK: - Today's Date

    private static func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
