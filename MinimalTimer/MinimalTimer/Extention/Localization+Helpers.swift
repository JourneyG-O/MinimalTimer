//
//  Localization+Helpers.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/9/25.
//

import Foundation

import SwiftUI

// MARK: - Localization Helpers
func L(_ key: String) -> LocalizedStringKey {
    LocalizedStringKey(key)
}

func LF(_ key: String, _ args: CVarArg...) -> String {
    String(format: NSLocalizedString(key, comment: ""), arguments: args)
}
