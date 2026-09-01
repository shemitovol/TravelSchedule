//
//  SearchBarView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 26.08.2026.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @State private var isSearching = false
    var placeholder = "Введите запрос"

    var body: some View {
        HStack (spacing: 0) {
            HStack (spacing: 0) {
                TextField(placeholder, text: $searchText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.ypBlack)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .padding(.leading, 33)
                    .cornerRadius(16)
                    .onTapGesture{
                        isSearching = true
                    }
                    .overlay(
                        HStack {
                            if isSearching && searchText.count > 0 {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.ypBlack)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                    .foregroundColor(.gray)
                            }
                            Spacer()

                            if isSearching && searchText.count > 0 {
                                Button(action: { searchText = "" }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.vertical)
                                })

                            }

                        }.padding(.horizontal, 8)
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 36)
            .background(Color.ypSearch)
            .cornerRadius(10)
        }
        .frame(height: 37)
        .padding(.horizontal, 16)
    }
}
