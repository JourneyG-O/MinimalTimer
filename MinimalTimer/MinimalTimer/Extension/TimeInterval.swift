//
//  TimeInterval.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/21/25.
//

import Foundation

extension TimeInterval {
    /// mm:ss 포맷 (예: 05:30)
    var mmss: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
