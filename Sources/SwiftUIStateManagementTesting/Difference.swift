/// Describes how two values differ, line by line, for failure messages.
enum Difference {
    /// The most lines of each side that a message shows.
    static let maximumLines = 60
    /// The most items `dump` writes for one value, so describing a huge state stays bounded.
    static let maximumDumpItems = 5_000

    /// Returns the lines of `dump(expected)` and `dump(actual)` that differ, after removing the
    /// lines both share at the start and at the end. `−` marks the expected value, `+` the actual
    /// one. Each side is cut to ``maximumLines``, so a large state gives a bounded message.
    static func lines<Value>(expected: Value, actual: Value) -> String {
        let expectedLines = dumpLines(expected)
        let actualLines = dumpLines(actual)

        var prefix = 0
        while prefix < expectedLines.count, prefix < actualLines.count,
              expectedLines[prefix] == actualLines[prefix] {
            prefix += 1
        }
        var suffix = 0
        while suffix < expectedLines.count - prefix, suffix < actualLines.count - prefix,
              expectedLines[expectedLines.count - 1 - suffix] == actualLines[actualLines.count - 1 - suffix] {
            suffix += 1
        }

        let removed = expectedLines[prefix..<(expectedLines.count - suffix)]
        let added = actualLines[prefix..<(actualLines.count - suffix)]
        var output: [String] = ["(−: expected, +: actual)"]
        if prefix > 0 { output.append("  " + expectedLines[prefix - 1]) }
        output += section(removed, marker: "−")
        output += section(added, marker: "+")
        if suffix > 0 { output.append("  " + expectedLines[expectedLines.count - suffix]) }
        return output.joined(separator: "\n")
    }

    private static func section(_ lines: ArraySlice<String>, marker: String) -> [String] {
        var result = lines.prefix(maximumLines).map { "\(marker) \($0)" }
        if lines.count > maximumLines {
            result.append("\(marker) … \(lines.count - maximumLines) more lines")
        }
        return result
    }

    private static func dumpLines<Value>(_ value: Value) -> [String] {
        var text = ""
        dump(value, to: &text, maxItems: maximumDumpItems)
        return text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }
}
