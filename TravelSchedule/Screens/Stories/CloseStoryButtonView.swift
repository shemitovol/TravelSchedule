//
//  CloseStoryButtonView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//
import SwiftUI

struct CloseStoryButton: View {
    let action: () -> Void

    var body: some View {
        Button{
            action()
        } label: {
            Image(.closeStory)
        }
        .foregroundStyle(Color.ypWhiteDay)
        .frame(width: 30, height: 30)
        .background(Color.ypBlackDay)
        .clipShape(Circle())
        .contentShape(Circle())
    }
}

#Preview {
    CloseStoryButton(action: {print("close")})
}
