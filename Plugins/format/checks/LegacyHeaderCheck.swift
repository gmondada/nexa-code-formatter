//
//  LegacyHeaderCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct LegacyHeaderCheck: ContentCheck {
    func run(url: URL, lines: inout [String]) -> [Issue] {
        guard let firstLine = lines.first else {
            return []
        }
        guard firstLine == "/*" else {
            return []
        }
        var headerEndIndex: Int = 0
        for index in 1..<lines.count {
            let line = lines[index]
            if line == " */" {
                headerEndIndex = index
                break
            }
            guard line.hasPrefix(" *") else {
                return []
            }
        }

        guard headerEndIndex > 0 else {
            return []
        }

        for index in (0 ..< headerEndIndex) {
            var line = lines[index]
            let startIndex = line.startIndex
            line.replaceSubrange(startIndex ..< line.index(startIndex, offsetBy: 2), with: "//")
            lines[index] = line
        }
        lines.remove(at: headerEndIndex)

        return [
            Issue(description: "Converted legacy /* */ header to // style", line: 1, autoFixed: true)
        ]
    }
}
