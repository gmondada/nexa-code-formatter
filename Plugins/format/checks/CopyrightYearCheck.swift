//
//  CopyrightYearCheck.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct CopyrightYearCheck: HeaderCheck {
    func run(url: URL, header: Header) -> [Issue] {
        if let notice = header.legalNotices.first, case .created(_, let date) = notice.origin {
            let year = Calendar.current.component(.year, from: date)
            if notice.year != year {
                header.legalNotices[0].year = year
                return [Issue(description: "Updated copyright year to match creation date", line: 0, autoFixed: true)]
            }
        }
        return []
    }
}
