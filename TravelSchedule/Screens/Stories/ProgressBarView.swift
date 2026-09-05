//
//  ProgressBarView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 04.09.2026.
//

import SwiftUI

struct ProgressBarView: View {
    let numberOfSection: Int
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .progressBarCornerRadius)
                    .frame(width: geometry.size.width, height: .progressBarHeight)
                    .foregroundStyle(Color.ypWhiteDay)

                RoundedRectangle(cornerRadius: .progressBarCornerRadius)
                    .frame(
                        width: min(
                            progress * geometry.size.width,
                            geometry.size.width
                        ),
                        height: .progressBarHeight
                    )
                    .foregroundStyle(Color.ypBlue)
            }
            .mask {
                MaskView(numberOfSections: numberOfSection)
            }
        }
    }
}

struct MaskFragmentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: .progressBarCornerRadius)
            .foregroundStyle(Color.ypWhiteDay)
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: .progressBarHeight)
    }
}

struct MaskView: View {
    let numberOfSections: Int

    var body: some View {
        HStack{
            ForEach(0..<numberOfSections, id: \.self) { _ in
                MaskFragmentView()
            }
        }
    }
}

#Preview {
    ProgressBarView(numberOfSection: 5, progress: 0.5)
}
