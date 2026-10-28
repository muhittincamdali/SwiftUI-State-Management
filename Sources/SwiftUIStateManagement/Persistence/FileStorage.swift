import Foundation

/// Stores each value in its own JSON file in a directory.
///
/// ```swift
/// let storage = try FileStorage.applicationSupport()
/// ```
///
/// - Files are written atomically: a crash during a write leaves the previous file in place.
/// - On iOS, iPadOS, tvOS, watchOS and visionOS, files use the data protection class
///   `completeUntilFirstUserAuthentication`.
/// - A key's name becomes the file name (`<name>.json`). Names are checked, so a name cannot
///   point outside the directory.
/// - The file size is checked before reading, and at most `maxBytes + 1` bytes are ever read.
public struct FileStorage: StateStorage {
    /// The directory that holds the files. Created on the first write.
    public let directory: URL

    /// Creates a storage in `directory`.
    public init(directory: URL) {
        self.directory = directory
    }

    /// Returns a storage in a subdirectory of the app's Application Support directory.
    ///
    /// - Parameter subdirectory: The name of the subdirectory; `"State"` by default.
    public static func applicationSupport(subdirectory: String = "State") throws -> FileStorage {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return FileStorage(directory: base.appending(path: subdirectory, directoryHint: .isDirectory))
    }

    public func data(forKey key: String, maxBytes: Int) throws -> Data? {
        let url = try fileURL(forKey: key)
        guard maxBytes > 0 else {
            throw PersistenceError.invalidKey("maxBytes must be greater than zero.")
        }
        let handle: FileHandle
        do {
            handle = try FileHandle(forReadingFrom: url)
        } catch CocoaError.fileReadNoSuchFile, CocoaError.fileNoSuchFile {
            return nil
        }
        defer { try? handle.close() }

        let size = try handle.seekToEnd()
        guard size <= UInt64(maxBytes) else {
            throw PersistenceError.tooLarge(byteCount: Int(clamping: size), limit: maxBytes)
        }
        try handle.seek(toOffset: 0)
        // Read one byte more than allowed, so a file that grew after the size check is caught
        // without reading all of it.
        let (readLimit, overflow) = maxBytes.addingReportingOverflow(1)
        let data = try handle.read(upToCount: overflow ? maxBytes : readLimit) ?? Data()
        guard data.count <= maxBytes else {
            throw PersistenceError.tooLarge(byteCount: data.count, limit: maxBytes)
        }
        return data
    }

    public func setData(_ data: Data, forKey key: String) throws {
        let url = try fileURL(forKey: key)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: url, options: Self.writingOptions)
    }

    public func removeData(forKey key: String) throws {
        let url = try fileURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch CocoaError.fileNoSuchFile {
            return
        }
    }

    /// The file for `key`, after checking that the name is a plain file name.
    func fileURL(forKey key: String) throws -> URL {
        guard PersistenceKey<Int>.isValidName(key) else {
            throw PersistenceError.invalidKey("The name must be 1 to 128 characters from A-Z, a-z, 0-9, '.', '_' and '-', not starting with '.'.")
        }
        return directory.appending(path: key + ".json", directoryHint: .notDirectory)
    }

    private static var writingOptions: Data.WritingOptions {
        #if os(macOS)
        [.atomic]
        #else
        [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        #endif
    }
}
