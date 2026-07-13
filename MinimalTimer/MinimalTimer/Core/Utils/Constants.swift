//
//  Constants.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/13/25.
//

import Foundation

enum Constants {
    enum Time {
        /// 생성 가능한 최대 시간(분)
        static let maxMinutes: Int = 120

        /// 이 값 미만이면 '초' 단위 스냅/눈금, 이상이면 '분' 단위
        static let snapSecondThreshold: TimeInterval = 5 * 60
    }

    enum Purchase {
        /// 무료 사용자가 생성할 수 있는 최대 타이머 개수
        static let freeTimerLimit: Int = 3
    }
}
