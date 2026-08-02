import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
            testFetchStations()
            testFetchCopyright()
            testFetchScheduleBetweenStations()
            testFetchStationSchedule()
            testFetchRouteStations()
            testFetchNearestCity()
            testFetchCarrierInfo()
            testFetchAllStations()
        }
    }
}

#Preview {
    ContentView()
}
