//
//  Check.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct Issue {
    let description: String
    let line: Int
    let autoFixed: Bool
}

protocol ContentCheck {
    func run(url: URL, lines: inout [String]) -> [Issue]
}

protocol HeaderCheck {
    func run(url: URL, header: Header) -> [Issue]
}
