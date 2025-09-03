//
//  String+Extansion.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/3/25.
//

extension String {
    /// 제목에 CJK-like 문자(한글/한자/히라가나/가타카나)가 포함되어 있는지
    var isCJKLike: Bool {
        // 한자: \u4E00-\u9FFF, \u3400-\u4DBF(확장A), \uF900-\uFAFF(호환)
        // 히라가나: \u3040-\u309F
        // 가타카나: \u30A0-\u30FF
        // 한글: \uAC00-\uD7A3(완성형), \u1100-\u11FF(자모), \u3130-\u318F(호환 자모)
        let pattern = #"[\u4E00-\u9FFF\u3400-\u4DBF\uF900-\uFAFF\u3040-\u309F\u30A0-\u30FF\uAC00-\uD7A3\u1100-\u11FF\u3130-\u318F]"#
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}
