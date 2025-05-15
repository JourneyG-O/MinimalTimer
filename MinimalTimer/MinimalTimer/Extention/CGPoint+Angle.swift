//
//  CGPoint+Angle.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/15/25.
//

import Foundation

// 파일 생성해서 이동해야 하는 부분
extension CGPoint {

    // point 위치를 각도로 변환
    func angle(to point: CGPoint) -> Double {
        let dx = point.x - self.x
        let dy = point.y - self.y
        var angle = atan2(dy, dx) * 180 / .pi
        angle = angle < -90 ? angle + 450 : angle + 90
        return min(max(angle, 0), 360)
    }
}
