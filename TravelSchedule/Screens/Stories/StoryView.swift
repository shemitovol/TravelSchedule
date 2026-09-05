//
//  StoryView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//

import SwiftUI

struct StoryView: View {
    let story: Story

    var body: some View {
        Color.ypBlackDay
            .ignoresSafeArea()
            .overlay (
                ZStack {
                    story.cover
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Spacer()
                        VStack (alignment: .leading, spacing: 16) {
                            Text(story.title)
                                .font(.bold34)
                                .foregroundStyle(Color.ypWhiteDay)
                                .lineLimit(2)

                            Text(story.description)
                                .font(.regular20)
                                .foregroundStyle(Color.ypWhiteDay)
                                .lineLimit(3)
                        }
                        .padding(.init(top: 0, leading: 16, bottom: 40, trailing: 16))
                    }
                }
            )
    }
}

#Preview {
    StoryView(story: Story.stories[1])
}
