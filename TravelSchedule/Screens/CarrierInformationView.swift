//
//  CarrierInformationView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 05.09.2026.
//

import SwiftUI

struct CarrierInformationView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let logo: String?
    let email: String
    let phone: String

    var body: some View {
        VStack {
            Group {
                if let logo,
                   let url = URL(string: logo) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(.wideLogoChecker)
                            .resizable()
                            .scaledToFit()
                    }

                } else {
                    Image(.wideLogoChecker)
                        .resizable()
                        .scaledToFit()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .padding(16)

            Text(title)
                .font(.bold24)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                if !email.isEmpty {
                    HStack {
                        VStack (alignment: .leading) {
                            Text("E-mail")
                                .font(.regular17)
                            Text(email)
                                .font(.regular12)
                                .foregroundStyle(Color.ypBlue)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("Телефон")
                            .font(.regular17)
                        Text(phone)
                            .font(.regular12)
                            .foregroundStyle(Color.ypBlue)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .opacity(phone.isEmpty ? 0 : 1)

            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 16)
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Информация о перевозчике")
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
    }
}

