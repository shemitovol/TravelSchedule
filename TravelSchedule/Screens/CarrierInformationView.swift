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
            if let logo,
               let url = URL(string: logo) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(.wideLogoChecker)
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .frame(height: 104)
                .padding(16)
            } else {
                Image(.wideLogoChecker)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .frame(height: 104)
                    .padding(16)
            }

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

                if !phone.isEmpty {
                    HStack {
                        VStack (alignment: .leading) {
                            Text("Phone")
                                .font(.regular17)
                            Text(phone)
                                .font(.regular12)
                                .foregroundStyle(Color.ypBlue)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
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

