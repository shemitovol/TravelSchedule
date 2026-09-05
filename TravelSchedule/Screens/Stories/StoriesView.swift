//
//  StoriesView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//

import SwiftUI

struct StoriesView: View {
    @State private var viewModel: StoriesViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var touchLocation: CGPoint = .zero

    let onClose: () -> Void
    let onStoryViewed: (Int) -> Void

    init(
        stories: [Story] = Story.stories,
        initialIndex: Int = 0,
        onClose: @escaping () -> Void,
        onStoryViewed: @escaping (Int) -> Void
    ) {
        _viewModel = State(
            wrappedValue: StoriesViewModel(
                stories: stories,
                initialIndex: initialIndex
            )
        )
        self.onClose = onClose
        self.onStoryViewed = onStoryViewed
    }

    var body: some View {
        ZStack {
            Color.ypBlackDay
                .ignoresSafeArea()
                .opacity(1 - min(dragOffset / 400, 1))

            ZStack(alignment: .topTrailing) {
                StoryView(story: viewModel.currentStory, isPreview: false)

                ProgressBarView(
                    numberOfSection: viewModel.stories.count,
                    progress: viewModel.progress
                )
                .padding(.init(top: 28, leading: 12, bottom: 12, trailing: 12))

                CloseStoryButton {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dragOffset = UIScreen.main.bounds.height
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onClose()
                    }
                }
                .padding(.top, 57)
                .padding(.trailing, 12)
            }
            .offset(y: dragOffset)
        }
        .onAppear {
            viewModel.start()
        }
        .onChange(of: viewModel.currentStoryIndex) {
            onStoryViewed(viewModel.currentStoryIndex)
        }
        .onDisappear {
            viewModel.stop()
        }
        .contentShape(Rectangle())
        .gesture (
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        touchLocation = value.startLocation
                        viewModel.stop()
                    }
                    
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    isDragging = false

                    if value.translation.height > 100 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dragOffset = UIScreen.main.bounds.height
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onClose()
                        }
                        return
                    }

                    if value.translation.height < 10 {
                        let screenWidth = UIScreen.main.bounds.width

                        if touchLocation.x < screenWidth / 2 {
                            viewModel.previousStory()
                        } else {
                            viewModel.nextStory()
                        }
                    }

                    withAnimation(.easeInOut(duration: 0.3)) {
                        dragOffset = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.start()
                    }
                }
        )
    }
}

