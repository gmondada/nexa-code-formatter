//
//  GitUtils.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 26, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

struct GitUtils {
    static func appearingDate(of url: URL) -> Date? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", "touch /tmp/__git_date; rm /tmp/__git_date; cd \"\(url.deletingLastPathComponent().path)\"; git log --format=%aI -- \(url.lastPathComponent) | tail -1 > /tmp/__git_date"]
        try? task.run()
        task.waitUntilExit()
        let dateString = try! String.init(contentsOf: URL(string:"file:///tmp/__git_date")!, encoding: .utf8)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
