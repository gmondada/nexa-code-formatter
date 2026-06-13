//
//  Header.swift
//  gm mit
//
//  Created by Gabriele Mondada on January 25, 2026.
//  Copyright (c) 2026 Gabriele Mondada.
//  MIT License. See the file LICENSE for details.
//

import Foundation

class Header {
    enum Origin {
        case created(by: String, date: Date)
        case derived(description: String)
    }

    struct LegalNotice {
        // Line 1: Origin
        var origin: Origin

        // line 2: Copyright
        var message: String
        var owner: String
        var year: Int
        var rights: String?

        // line 3: License/distribution
        var license: String?
    }

    var filename: String
    var project: String?

    var legalNotices: [LegalNotice] = []

    var extraLines: [String] = []

    var hasCleanDateFormat = true

    var tags: [String] {
        get {
            if let project {
                return project.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            }
            return []
        }
        set {
            if newValue.isEmpty {
                project = nil
            } else {
                project = newValue.joined(separator: ", ")
            }
        }
    }

    init(url: URL, config: Config) {
        filename = url.lastPathComponent
        guard let project = config.projects.first else {
            fatalError("No project defined in the configuration")
        }
        guard case .primary(_) = project.type else {
            fatalError("First project must be primary")
        }
        self.project = project.tag
    }

    init(lines: [String]) throws {
        var textLines: [String] = []
        var index = 0

        // extract pure text

        for index in 0 ..< lines.count {
            guard lines[index].hasPrefix("//") else {
                throw FormatError("Header line must start by //")
            }
            if lines[index].hasPrefix("//  ") {
                textLines.append(lines[index].substring(4))
            } else if lines[index] == "// " {
                textLines.append(lines[index].substring(3))
            } else {
                textLines.append(lines[index].substring(2))
            }
        }

        // skip initial empty line

        guard index < textLines.count && textLines[index] == "" else {
            throw FormatError("Header must start with an empty line")
        }
        index += 1

        // parse filename

        guard index < textLines.count && textLines[index] != "" else {
            throw FormatError("Missing filename line in header")
        }
        filename = textLines[index].trimmingCharacters(in: .whitespacesAndNewlines)
        index += 1

        // parse project

        guard index < textLines.count else {
            throw FormatError("Expeced project line or empty line after filename in header")
        }
        if textLines[index] != "" {
            project = textLines[index]
            index += 1
        } else {
            project = nil
        }

        // skip empty line

        guard index < textLines.count && textLines[index] == "" else {
            throw FormatError("Expected empty line after project in header")
        }
        index += 1

        // parse legal notices

        while true {
            if index >= textLines.count {
                break
            }

            // parse origin

            let origin: Origin

            if textLines[index].hasPrefix("Created by") {
                let creation = textLines[index]

                guard let r1 = creation.range(of: "Created by "),
                    let r2 = creation.range(of: " on "),
                    creation.last == "." else
                {
                    throw FormatError("Invalid creation line format in header")
                }

                let user = String(creation[r1.upperBound ..< r2.lowerBound])
                let dateString = String(creation[r2.upperBound..<creation.index(creation.endIndex, offsetBy: -1)])

                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "dd.MM.yy"
                dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter1.timeZone = TimeZone(secondsFromGMT: 0)
                var date = dateFormatter1.date(from:dateString)
                if date == nil {
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.dateFormat = "MMM d, yyyy"
                    dateFormatter2.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter2.timeZone = TimeZone(secondsFromGMT: 0)
                    date = dateFormatter2.date(from:dateString)
                }
                guard let date else {
                    throw FormatError("Invalid date format in header")
                }
                if dateString != Self.formatDate(date) {
                    hasCleanDateFormat = false
                }
                index += 1
                origin = .created(by: user, date: date)
            } else if textLines[index].hasPrefix("Derived from") {
                let description = textLines[index]
                index += 1
                origin = .derived(description: description)
            } else {
                break
            }

            // parse copyright line

            let line = textLines[index]

            let pattern = #"(?<copyright>Copyright (©|\(c\))) (?<year>\d{4}) (?<owner>[^\.]*)\.\s*(?<rights>.*)"#
            let regex = try! NSRegularExpression(pattern: pattern, options: [])

            let nsrange = NSRange(line.startIndex ..< line.endIndex, in: line)
            guard let match = regex.firstMatch(in: line, options: [], range: nsrange) else {
                throw FormatError("Invalid copyright line format in header")
            }

            let nsr1 = match.range(withName: "copyright")
            if nsr1.location == NSNotFound {
                throw FormatError("Invalid copyright line format in header")
            }
            let r1 = Range(nsr1, in: line)!
            let message = String(line[r1])

            let nsr2 = match.range(withName: "year")
            if nsr2.location == NSNotFound {
                throw FormatError("Invalid copyright line format in header")
            }
            let r2 = Range(nsr2, in: line)!
            let year = Int(String(line[r2]))!

            let nsr3 = match.range(withName: "owner")
            if nsr3.location == NSNotFound {
                throw FormatError("Invalid copyright line format in header")
            }
            let r3 = Range(nsr3, in: line)!
            let owner = String(line[r3])

            let rights: String?
            let nsr4 = match.range(withName: "rights")
            if nsr4.location != NSNotFound && nsr4.length > 0 {
                let r4 = Range(nsr4, in: line)!
                rights = String(line[r4])
            } else {
                rights = nil
            }

            index += 1

            // parse license

            let license: String?
            if index < textLines.count && textLines[index] != "" {
                license = textLines[index]
                index += 1
            } else {
                license = nil
            }

            // skip empty line

            guard index < textLines.count && textLines[index] == "" else {
                throw FormatError("Expected empty line after legal notice in header")
            }
            index += 1

            // store project info

            legalNotices.append(LegalNotice(origin: origin, message: message, owner: owner, year: year, rights: rights, license: license))
        }

        // check to be at the end of the header

        if index < textLines.count {
            guard textLines[index] != "" else {
                throw FormatError("Expected single empty line after legal notices in header")
            }
            guard textLines[textLines.count - 1] == "" else {
                throw FormatError("Expected empty line at end of header")
            }
            extraLines = Array(textLines[index..<textLines.count - 1])
        }
    }

    func format() -> [String] {
        var ret = [String]()
        ret.append("//")
        ret.append("//  \(filename)")
        if let p = project {
            ret.append("//  \(p)")
        }
        ret.append("//")
        for legalNotice in legalNotices {
            switch legalNotice.origin {
            case .created(let user, let date):
                let dateString = Self.formatDate(date)
                ret.append("//  Created by \(user) on \(dateString).")
            case .derived(let description):
                ret.append("//  \(description)")
            }
            var rights = ""
            if let r = legalNotice.rights {
                rights = " " + r
            }
            ret.append("//  \(legalNotice.message) \(legalNotice.year) \(legalNotice.owner).\(rights)")
            if let license = legalNotice.license {
                ret.append("//  \(license)")
            }
            ret.append("//")
        }
        for line in extraLines {
            ret.append("//  \(line)".trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if !extraLines.isEmpty {
            ret.append("//")
        }
        return ret
    }

    private static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
}
