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
        let deltaX = point.x - self.x
        let deltaY = point.y - self.y
        var angle = atan2(deltaY, deltaX) * 180 / .pi
        angle = angle < -90 ? angle + 450 : angle + 90
        return min(max(angle, 0), 360)
    }
}
