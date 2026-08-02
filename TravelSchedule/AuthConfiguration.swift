import Foundation

enum Constants {
    static let apiKey = "24cd3631-074f-46f1-bfe2-208db2d9d135"
}

struct AuthConfiguration {
    let apiKey: String

    init (apiKey: String) {
        self.apiKey = apiKey
    }

    static var standard: AuthConfiguration{
        return AuthConfiguration(apiKey: Constants.apiKey,)
    }
}

