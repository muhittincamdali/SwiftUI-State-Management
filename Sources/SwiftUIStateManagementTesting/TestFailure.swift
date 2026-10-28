#if canImport(Testing)
import Testing
#endif
#if canImport(XCTest)
import XCTest
#endif

/// Where an assertion was written, so that a failure points at the test's own line.
struct FailureLocation: Sendable {
    let fileID: StaticString
    let filePath: StaticString
    let line: UInt
    let column: UInt
}

/// Records a test failure in the running Swift Testing test, or in the running XCTest test case.
func recordFailure(_ message: String, at location: FailureLocation) {
    #if canImport(Testing)
    if Test.current != nil {
        Issue.record(
            Comment(rawValue: message),
            sourceLocation: SourceLocation(
                fileID: String(describing: location.fileID),
                filePath: String(describing: location.filePath),
                line: max(1, Int(clamping: location.line)),
                column: max(1, Int(clamping: location.column))
            )
        )
        return
    }
    #endif
    #if canImport(XCTest)
    XCTFail(message, file: location.filePath, line: location.line)
    #endif
}
