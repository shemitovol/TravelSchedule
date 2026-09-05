//
//  StoryView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//

import SwiftUI

struct StoryView: View {
    let story: Story
    let isPreview: Bool

    var body: some View {
        if isPreview {
            ZStack {
                story.cover
                    .resizable()
                    .scaledToFill()
                    .frame(width: 92, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack {
                    Spacer()
                    Text(story.title)
                        .font(.regular12)
                        .foregroundStyle(Color.ypWhiteDay)
                        .lineLimit(3)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
            .frame(width: 92, height: 140)
        } else {
            ZStack {
                story.cover
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 16) {
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
        }
    }
}

#Preview {
    StoryView(story: Story.stories[1], isPreview: true)
}
