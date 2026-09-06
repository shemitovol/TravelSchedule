//
//  StoriesViewModel.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 05.09.2026.
//

import SwiftUI
import Combine

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
    private var timer: Timer.TimerPublisher?
    private var timerConnection: Cancellable?
    private var cancellable: Cancellable?

    private(set) var progress: CGFloat = 0

    init(stories: [Story] = Story.stories, initialIndex: Int = 0) {
        self.stories = stories
        self.configuration = Configuration(storiesCount: stories.count)
        progress = CGFloat(initialIndex) / CGFloat(stories.count)
    }

    func start() {
        guard cancellable == nil else { return }
        let timer = Self.createTimer(configuration: configuration)
        self.timer = timer
        cancellable = timer
            .sink { [weak self] _ in
                self?.timerTick()
            }
        timerConnection = timer.connect()
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
        timerConnection?.cancel()
        timerConnection = nil
        timer = nil
    }

    func nextStory() {
        let nextStoryIndex = currentStoryIndex + 1 < stories.count
        ? currentStoryIndex + 1
        : 0
        withAnimation {
            progress = CGFloat(nextStoryIndex) / CGFloat(stories.count)
        }
        resetTimer()
    }

    func previousStory() {
        let previousStoryIndex = currentStoryIndex > 0
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

    private static func createTimer(configuration: Configuration) -> Timer.TimerPublisher {
        Timer
            .publish(
                every: configuration.timerTickInterval,
                on: .main,
                in: .common
            )
    }

    deinit {
        stop()
    }
}
