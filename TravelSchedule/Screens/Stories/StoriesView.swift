//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//

import SwiftUI

struct StoriesView: View {
    @State private var viewModel: StoriesViewModel

    init(stories: [Story] = Story.stories) {
        _viewModel = State(
            wrappedValue: StoriesViewModel(stories: stories)
        )
    }

    var body: some View {
        ZStack (alignment: .topTrailing) {
            StoryView(story: viewModel.currentStory)

            ProgressBarView(
                numberOfSection: viewModel.stories.count,
                progress: viewModel.progress
            )
            .padding(.init(top: 28, leading: 12, bottom: 12, trailing: 12))

            CloseStoryButton {
                print("Close story")
            }
                .padding(.top, 57)
                .padding(.trailing, 12)
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .onTapGesture {
            viewModel.nextStory()
        }
    }
}

#Preview {
    StoriesView()
}
