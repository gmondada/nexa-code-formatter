//
//  ExoticCharCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct ExoticCharCheck: ContentCheck {
    func run(url: URL, lines: inout [String]) -> [Issue] {
        for index in 0..<lines.count {
            let line = lines[index]
            for scalar in line.unicodeScalars {
                if (scalar.value < 32 && scalar.value != 9) {
                    return [Issue(description: "Exotic char '\(scalar)' [\(scalar.value)] found", line: index + 1, autoFixed: false)]
                }
            }
        }
        return []
    }
}
