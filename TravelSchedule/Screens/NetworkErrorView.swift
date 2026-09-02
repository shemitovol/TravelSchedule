//
//  NetworkErrorView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 29.08.2026.
//

import SwiftUI

struct NetworkErrorView: View {
    enum ErrorType {
        case network
        case server
    }

    let errorType: ErrorType

    var body: some View {
        VStack {
            switch errorType {
            case .network:
                Image(.noInternet)
                    .resizable()
                    .frame(width: 223, height: 223)
                    .clipShape(RoundedRectangle(cornerRadius: 70))

                Text("Нет интернета")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.ypBlack)
            case .server:
                Image(.serverError)
                    .resizable()
                    .frame(width: 223, height: 223)
                    .clipShape(RoundedRectangle(cornerRadius: 70))

                Text("Ошибка сервера")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.ypBlack)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ypWhite)
    }
}
