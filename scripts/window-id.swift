// Prints the window number of the largest on-screen window of a process, for `screencapture -l`.
// Usage: swift scripts/window-id.swift <pid>
import CoreGraphics

guard CommandLine.arguments.count == 2, let pid = Int(CommandLine.arguments[1]) else {
    print("usage: window-id.swift <pid>")
    exit(2)
}
let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
func area(_ window: [String: Any]) -> Double {
    let bounds = window[kCGWindowBounds as String] as? [String: Double] ?? [:]
    return (bounds["Width"] ?? 0) * (bounds["Height"] ?? 0)
}
let match = windows
    .filter { window in
        window[kCGWindowOwnerPID as String] as? Int == pid
            && window[kCGWindowLayer as String] as? Int == 0
            && window[kCGWindowIsOnscreen as String] as? Bool == true
    }
    .max { area($0) < area($1) }
guard let number = match?[kCGWindowNumber as String] as? Int else { exit(1) }
print(number)
