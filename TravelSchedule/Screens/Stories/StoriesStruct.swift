//
//  StoriesStruct.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//

import SwiftUI

struct Story {
    let cover: Image
    let title: String
    let description: String

    init(cover: Image) {
        self.cover = cover
        self.title = String(
            repeating: "Text ", count: Int.random(in: 8...20)
            )
        self.description = String(
            repeating: "Text ", count: Int.random(in: 15...30)
            )
    }

    static let stories: [Story] = [
        Story(cover: Image(.story1)),
        Story(cover: Image(.story2)),
        Story(cover: Image(.story3)),
        Story(cover: Image(.story4)),
        Story(cover: Image(.story5)),
        Story(cover: Image(.story6)),
        Story(cover: Image(.story7)),
        Story(cover: Image(.story8)),
        Story(cover: Image(.story9)),
        Story(cover: Image(.story10)),
        Story(cover: Image(.story11)),
        Story(cover: Image(.story12)),
        Story(cover: Image(.story13)),
        Story(cover: Image(.story14)),
        Story(cover: Image(.story15)),
        Story(cover: Image(.story16)),
        Story(cover: Image(.story17)),
        Story(cover: Image(.story18))
    ]
}
