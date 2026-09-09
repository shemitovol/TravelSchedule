//
//  StoriesViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 05.09.2026.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class StoriesViewModel {
    struct Configuration {
        let timerTickInterval: TimeInterval
        let progressPerTick: CGFloat

        init(
            storiesCount: Int,
            secondsPerStory: TimeInterval = 5,
            timerTickInterval: TimeInterval = 0.05
        ) {
            self.timerTickInterval = timerTickInterval
            self.progressPerTick = 1 / CGFloat(storiesCount) / secondsPerStory * timerTickInterval
        }
    }

    var currentStory: Story { stories[currentStoryIndex] }
    var currentStoryIndex: Int { Int(progress * CGFloat(stories.count)) }
    let stories: [Story]
    private let configuration: Configuration
    private var timerTask: Task<Void, Never>?
    private(set) var progress: CGFloat = 0

    init(stories: [Story] = Story.stories, initialIndex: Int = 0) {
        self.stories = stories
        self.configuration = Configuration(storiesCount: stories.count)
        progress = CGFloat(initialIndex) / CGFloat(stories.count)
    }

    func start() {
        guard timerTask == nil else { return }

        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(
                        nanoseconds: UInt64(
                            configuration.timerTickInterval
                            * 1_000_000_000
                        )
                    )
                } catch {
                    return
                }

                guard !Task.isCancelled else { return }

                timerTick()
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    func nextStory() {
        let nextStoryIndex =
            currentStoryIndex + 1 < stories.count
            ? currentStoryIndex + 1
            : 0

        withAnimation {
            progress = CGFloat(nextStoryIndex) / CGFloat(stories.count)
        }

        resetTimer()
    }

    func previousStory() {
        let previousStoryIndex =
            currentStoryIndex > 0
            ? currentStoryIndex - 1
            : stories.count - 1

        withAnimation {
            progress = CGFloat(previousStoryIndex) / CGFloat(stories.count)
        }

        resetTimer()
    }

    private func timerTick() {
        var nextProgress = progress + configuration.progressPerTick

        if nextProgress >= 1 {
            nextProgress = 0
        }

        withAnimation {
            progress = nextProgress
        }
    }

    private func resetTimer() {
        stop()
        start()
    }
}
