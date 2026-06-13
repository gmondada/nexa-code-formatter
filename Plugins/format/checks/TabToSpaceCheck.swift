//
//  TabToSpaceCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct TabToSpaceCheck: ContentCheck {
    func run(url: URL, lines: inout [String]) -> [Issue] {
        var issues: [Issue] = []
        for (index, line) in lines.enumerated() {
            if let line = convertTabsToSpaces(line) {
                lines[index] = line
                issues.append(Issue(description: "Converted tabs to spaces", line: index + 1, autoFixed: true))
            }
        }
        return issues
    }

    func convertTabsToSpaces(_ originalLine: String) -> String? {
        var line = originalLine
        var altered = false
        scan: while true {
            var pos = 0
            for c in line {
                if c == "\t" {
                    let index = line.index(line.startIndex, offsetBy: pos)
                    let spaceCount = 4 - (pos % 4)
                    let spaces = String([Character].init(repeating: " ", count: spaceCount))
                    line.remove(at: index)
                    line.insert(contentsOf: spaces, at: index)
                    altered = true
                    continue scan
                }
                pos += 1
            }
            break
        }
        return altered ? line : nil
    }
}
