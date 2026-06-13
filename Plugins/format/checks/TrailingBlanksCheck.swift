//
//  TrailingBlanksCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct TrailingBlanksCheck: ContentCheck {
    func run(url: URL, lines: inout [String]) -> [Issue] {
        var issues: [Issue] = []
        for (index, line) in lines.enumerated() {
            if let line = removeTrailingBlanks(line) {
                lines[index] = line
                issues.append(Issue(description: "Removed trailing blanks", line: index + 1, autoFixed: true))
            }
        }
        return issues
    }

    func removeTrailingBlanks(_ originalLine: String) -> String? {
        var line = originalLine
        var altered = false
        while true {
            if let last = line.last, last.unicodeScalars.count == 1 && last.unicodeScalars.first!.value <= 32 {
                // this is a blank
                line.removeLast()
                altered = true
            } else {
                break
            }
        }
        return altered ? line : nil
    }
}
