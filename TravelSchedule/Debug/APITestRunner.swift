//
//  APITestRunner.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 03.08.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum APITestRunner {
    static func runAll() async {
        do {
            let tester = try APITester()
            await tester.testRawScheduleBetweenStations()
        } catch {
            print("Failed to create TestServices: \(error)")
        }
    }
}

final class APITester {
    //MARK: - Initialization
    private let client: Client
    private let configuration = AuthConfiguration.standard

    init() throws {
        self.client = Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport()
        )
    }

    //MARK: - Private Properties
    private enum TestData {
        static let carrierCode = "66067"
        static let lat = 59.864177
        static let lng = 30.319163
        static let distance = 50
        static let uid = "SU-1942_260802_c26_12"
        static let station = "s9600213"
        static let city = "c146"
    }

    private lazy var allStationsService = AllStationsService(client: client, apikey: configuration.apiKey)
    private lazy var carrierInfoService = CarrierInfoService(client: client, apikey: configuration.apiKey)
    private lazy var copyrightService = CopyrightService(client: client, apikey: configuration.apiKey)
    private lazy var nearestCityService = NearestCityService(client: client, apikey: configuration.apiKey)
    private lazy var nearestStationsService = NearestStationsService(client: client, apikey: configuration.apiKey)
    private lazy var routeStationsService = RouteStationsService(client: client, apikey: configuration.apiKey)
    private lazy var schedualBetweenStationsService = SchedualBetweenStationsService(client: client, apikey: configuration.apiKey)
    private lazy var stationScheduleService = StationScheduleService(client: client, apikey: configuration.apiKey)

    //MARK: - Public Methods
    func testFetchAllStations() async {
        do {
            print("Fetching all stations...")
            let allStations = try await allStationsService.getAllStations()
            let countries = allStations.countries ?? []
            print("Countries: \(countries.count)")
            let regions = countries.flatMap { $0.regions ?? []}
            print("Regions: \(regions.count)")
            let settlements = regions.flatMap { $0.settlements ?? []}
            print("Settlements: \(settlements.count)")
            let stations = settlements.flatMap { $0.stations ?? []}
            print("Successfully fetched all stations: \(stations.count)")
        } catch {
            print("Error fetching all stations: \(error)")
        }
    }

    func testFetchCarrierInfo() async {
        do {
            print("Fetching carrier info...")
            let carrierInfo = try await carrierInfoService.getCarrierInfo(code: TestData.carrierCode)
            print("Successfully fetched carrier info: \(carrierInfo)")
        } catch {
            print("Error fetching carrier info: \(error)")
        }
    }

    func testFetchCopyright() async {
        do {
            print("Fetching copyright...")
            let copyright = try await copyrightService.getCopyright()
            print("Successfully fetched copyright: \(copyright)")
        } catch {
            print("Error fetching copyright: \(error)")
        }
    }

    func testFetchNearestCity() async {
        do {
            print("Fetching city...")
            let city = try await nearestCityService.getNearestCity(
                lat: TestData.lat,
                lng: TestData.lng
            )
            print("Successfully fetched city: \(city)")
        } catch {
            print("Error fetching city: \(error)")
        }

    }

    func testFetchStations() async {
        do {
            print("Fetching stations...")
            let stations = try await nearestStationsService.getNearestStations(
                lat: TestData.lat,
                lng: TestData.lng,
                distance: TestData.distance
            )
            print("Successfully fetched stations: \(stations)")
        } catch {
            print("Error fetching stations: \(error)")
        }
    }

    func testFetchRouteStations() async {
        do {
            print("Fetching route stations...")
            let routeStations = try await routeStationsService.getRouteStations(uid: TestData.uid)
            print("Successfully fetched route stations: \(routeStations)")
        } catch {
            print("Error fetching route stations: \(error)")
        }
    }

    func testFetchScheduleBetweenStations() async {
        do {
            print("Fetching schedule between stations...")
            let scheduleBetweenStations = try await schedualBetweenStationsService.getSchedualBetweenStations(
                from: TestData.station,
                to: TestData.city,
                date: "2026-09-02",
                transfers: true
            )
            print("Successfully fetched schedule between stations: \(scheduleBetweenStations)")
        } catch {
            print("Error fetching schedule between stations: \(error)")
        }
    }
    
    func testFetchStationSchedule() async {
        do {
            print("Fetching station schedule...")
            let stationSchedule = try await stationScheduleService.getStationSchedule(station: TestData.station)
            print("Successfully fetched station schedule: \(stationSchedule)")
        } catch {
            print("Error fetching station schedule: \(error)")
        }
    }

    func testRawScheduleBetweenStations() async {
        do {
            let url = URL(
                string:
                    "https://api.rasp.yandex-net.ru/v3.0/search/"+"?apikey= \(configuration.apiKey)"+"&from=s9609235"+"&to=s9613034"+"&date=2026-09-02"+"&transfers=true"
            )!

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            print("==== RAW HTTP ====")
            if let httpResponse = response as? HTTPURLResponse {
                print("STATUS:", httpResponse.statusCode)
                print("HEADERS:", httpResponse.allHeaderFields)
            }
            print("==== BODY ====")
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            } else {
                print("Не удалось прочитать body как UTF-8")
            }
            print("==== END RAW HTTP ====")
        } catch {
            print("RAW HTTP ERROR:", error)
        }
    }
}
