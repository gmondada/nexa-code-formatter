//
//  CopyrightSymbolCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct CopyrightSymbolCheck: HeaderCheck {
    func run(url: URL, header: Header) -> [Issue] {
        var issues: [Issue] = []
        for (index, notice) in header.legalNotices.enumerated() {
            let message = notice.message.replacingOccurrences(of: "©", with: "(c)")
            if message != notice.message {
                header.legalNotices[index].message = message
                issues.append(Issue(description: "Replaced copyright symbol © with (c)", line: 0, autoFixed: true))
            }
        }
        return issues
    }
}
