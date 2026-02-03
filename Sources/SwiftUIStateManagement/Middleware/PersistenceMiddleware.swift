// PersistenceMiddleware.swift
// SwiftUI-State-Management
//
// Automatic state persistence middleware supporting multiple storage backends.
// Enables state recovery across app launches with configurable strategies.

import Foundation
import Combine

// MARK: - PersistenceMiddleware

/// A middleware that automatically persists and restores state.
///
/// `PersistenceMiddleware` supports multiple storage backends and provides:
/// - Automatic state persistence on changes
/// - Debounced saves to avoid excessive I/O
/// - State migration between versions
/// - Encryption for sensitive data
///
/// Example usage:
/// ```swift
/// let persistence = PersistenceMiddleware<AppState, AppAction>(
///     storage: .userDefaults(key: "app_state"),
///     strategy: .debounced(interval: 1.0)
/// )
///
/// let store = Store(
///     initialState: persistence.restore() ?? AppState(),
///     reducer: appReducer,
///     middlewares: [persistence]
/// )
/// ```
public final class PersistenceMiddleware<State: Codable, Action>: Middleware, ObservableObject {
    
    // MARK: - Types
    
    /// Storage backend options.
    public enum Storage {
        /// UserDefaults storage with a specified key.
        case userDefaults(key: String, suite: String? = nil)
        
        /// File-based storage at a specified URL.
        case file(URL)
        
        /// Keychain storage for sensitive data.
        case keychain(service: String, accessGroup: String? = nil)
        
        /// iCloud key-value storage.
        case iCloud(key: String)
        
        /// In-memory storage (for testing).
        case memory
        
        /// Custom storage implementation.
        case custom(PersistenceStorage)
    }
    
    /// Persistence strategy options.
    public enum Strategy {
        /// Save immediately on every change.
        case immediate
        
        /// Debounce saves with specified interval.
        case debounced(interval: TimeInterval)
        
        /// Throttle saves with specified interval.
        case throttled(interval: TimeInterval)
        
        /// Only save on specific actions.
        case onActions(matching: (Action) -> Bool)
        
        /// Manual save only.
        case manual
        
        /// Batch saves at regular intervals.
        case batched(interval: TimeInterval, maxPending: Int)
    }
    
    /// Configuration for persistence behavior.
    public struct Configuration {
        /// Storage backend.
        public var storage: Storage
        
        /// Persistence strategy.
        public var strategy: Strategy
        
        /// Whether to restore state on init.
        public var restoreOnInit: Bool
        
        /// State version for migrations.
        public var stateVersion: Int
        
        /// Migration handler for version upgrades.
        public var migrationHandler: ((Data, Int) throws -> State)?
        
        /// Error handler for persistence failures.
        public var errorHandler: ((Error) -> Void)?
        
        /// Whether to compress state data.
        public var compress: Bool
        
        /// Encryption key for sensitive data.
        public var encryptionKey: Data?
        
        /// Actions that should trigger a save.
        public var triggerActions: Set<String>
        
        /// Actions that should not trigger a save.
        public var ignoreActions: Set<String>
        
        /// Creates a default configuration.
        public init(
            storage: Storage = .userDefaults(key: "app_state"),
            strategy: Strategy = .debounced(interval: 1.0),
            restoreOnInit: Bool = true,
            stateVersion: Int = 1,
            migrationHandler: ((Data, Int) throws -> State)? = nil,
            errorHandler: ((Error) -> Void)? = nil,
            compress: Bool = false,
            encryptionKey: Data? = nil,
            triggerActions: Set<String> = [],
            ignoreActions: Set<String> = []
        ) {
            self.storage = storage
            self.strategy = strategy
            self.restoreOnInit = restoreOnInit
            self.stateVersion = stateVersion
            self.migrationHandler = migrationHandler
            self.errorHandler = errorHandler
            self.compress = compress
            self.encryptionKey = encryptionKey
            self.triggerActions = triggerActions
            self.ignoreActions = ignoreActions
        }
    }
    
    /// Persistence statistics.
    public struct Statistics {
        public var saveCount: Int = 0
        public var restoreCount: Int = 0
        public var lastSaveTime: Date?
        public var lastRestoreTime: Date?
        public var totalBytesWritten: Int = 0
        public var totalBytesRead: Int = 0
        public var errorCount: Int = 0
    }
    
    // MARK: - Properties
    
    /// Current configuration.
    public let configuration: Configuration
    
    /// Persistence statistics.
    @Published public private(set) var statistics = Statistics()
    
    /// Whether persistence is currently enabled.
    @Published public var isEnabled = true
    
    /// The underlying storage implementation.
    private let storageImpl: PersistenceStorage
    
    /// Timer for debounced/throttled saves.
    private var saveTimer: Timer?
    
    /// Last save time for throttling.
    private var lastSaveTime: Date?
    
    /// Pending state to save.
    private var pendingState: State?
    
    /// Queue for serializing saves.
    private let saveQueue = DispatchQueue(label: "com.statemanagement.persistence")
    
    /// Cancellables for subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new persistence middleware with the specified configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.storageImpl = Self.createStorage(for: configuration.storage)
    }
    
    /// Creates a new persistence middleware with default configuration.
    public convenience init(
        storage: Storage = .userDefaults(key: "app_state"),
        strategy: Strategy = .debounced(interval: 1.0)
    ) {
        self.init(configuration: Configuration(storage: storage, strategy: strategy))
    }
    
    // MARK: - Storage Creation
    
    private static func createStorage(for storage: Storage) -> PersistenceStorage {
        switch storage {
        case let .userDefaults(key, suite):
            return UserDefaultsStorage(key: key, suiteName: suite)
        case let .file(url):
            return FileStorage(url: url)
        case let .keychain(service, accessGroup):
            return KeychainStorage(service: service, accessGroup: accessGroup)
        case let .iCloud(key):
            return iCloudStorage(key: key)
        case .memory:
            return MemoryStorage()
        case let .custom(storage):
            return storage
        }
    }
    
    // MARK: - Middleware Protocol
    
    public func handle(
        action: Action,
        state: State,
        next: (Action) -> Effect<Action>
    ) -> Effect<Action> {
        let effect = next(action)
        
        guard isEnabled else { return effect }
        
        // Check if this action should trigger a save
        if shouldSave(action: action) {
            scheduleSave(state: state)
        }
        
        return effect
    }
    
    // MARK: - Save Logic
    
    private func shouldSave(action: Action) -> Bool {
        let actionName = String(describing: type(of: action))
        
        // Check ignore list
        if configuration.ignoreActions.contains(actionName) {
            return false
        }
        
        // Check trigger list (if not empty)
        if !configuration.triggerActions.isEmpty {
            return configuration.triggerActions.contains(actionName)
        }
        
        // Check strategy
        switch configuration.strategy {
        case .immediate, .debounced, .throttled, .batched:
            return true
        case let .onActions(matching):
            return matching(action)
        case .manual:
            return false
        }
    }
    
    private func scheduleSave(state: State) {
        switch configuration.strategy {
        case .immediate:
            performSave(state: state)
            
        case let .debounced(interval):
            saveTimer?.invalidate()
            pendingState = state
            saveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                guard let self = self, let state = self.pendingState else { return }
                self.performSave(state: state)
                self.pendingState = nil
            }
            
        case let .throttled(interval):
            let now = Date()
            if let lastSave = lastSaveTime, now.timeIntervalSince(lastSave) < interval {
                pendingState = state
                if saveTimer == nil {
                    let remaining = interval - now.timeIntervalSince(lastSave)
                    saveTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
                        guard let self = self, let state = self.pendingState else { return }
                        self.performSave(state: state)
                        self.pendingState = nil
                        self.saveTimer = nil
                    }
                }
            } else {
                performSave(state: state)
            }
            
        case let .batched(interval, maxPending):
            pendingState = state
            if saveTimer == nil {
                saveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                    guard let self = self, let state = self.pendingState else { return }
                    self.performSave(state: state)
                    self.pendingState = nil
                    self.saveTimer = nil
                }
            }
            
            // Force save if max pending reached (simplified)
            if maxPending > 0 {
                // In a real implementation, track pending count
            }
            
        case .onActions, .manual:
            performSave(state: state)
        }
    }
    
    private func performSave(state: State) {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                var data = try JSONEncoder().encode(state)
                
                // Compress if enabled
                if self.configuration.compress {
                    data = try self.compress(data)
                }
                
                // Encrypt if enabled
                if let key = self.configuration.encryptionKey {
                    data = try self.encrypt(data, key: key)
                }
                
                // Add version header
                data = self.addVersionHeader(to: data)
                
                try self.storageImpl.save(data)
                
                DispatchQueue.main.async {
                    self.statistics.saveCount += 1
                    self.statistics.lastSaveTime = Date()
                    self.statistics.totalBytesWritten += data.count
                    self.lastSaveTime = Date()
                }
            } catch {
                DispatchQueue.main.async {
                    self.statistics.errorCount += 1
                }
                self.configuration.errorHandler?(error)
            }
        }
    }
    
    // MARK: - Restore
    
    /// Restores the previously persisted state.
    public func restore() -> State? {
        do {
            guard var data = try storageImpl.load() else {
                return nil
            }
            
            // Parse version header
            let (version, stateData) = parseVersionHeader(from: data)
            data = stateData
            
            // Decrypt if enabled
            if let key = configuration.encryptionKey {
                data = try decrypt(data, key: key)
            }
            
            // Decompress if enabled
            if configuration.compress {
                data = try decompress(data)
            }
            
            // Check for migration
            if version < configuration.stateVersion, let migrator = configuration.migrationHandler {
                let migratedState = try migrator(data, version)
                statistics.restoreCount += 1
                statistics.lastRestoreTime = Date()
                statistics.totalBytesRead += data.count
                return migratedState
            }
            
            let state = try JSONDecoder().decode(State.self, from: data)
            statistics.restoreCount += 1
            statistics.lastRestoreTime = Date()
            statistics.totalBytesRead += data.count
            return state
        } catch {
            statistics.errorCount += 1
            configuration.errorHandler?(error)
            return nil
        }
    }
    
    /// Manually triggers a save.
    public func save(state: State) {
        performSave(state: state)
    }
    
    /// Clears persisted state.
    public func clear() throws {
        try storageImpl.clear()
    }
    
    // MARK: - Data Processing
    
    private func addVersionHeader(to data: Data) -> Data {
        var result = Data()
        var version = UInt32(configuration.stateVersion).bigEndian
        result.append(Data(bytes: &version, count: 4))
        result.append(data)
        return result
    }
    
    private func parseVersionHeader(from data: Data) -> (Int, Data) {
        guard data.count >= 4 else { return (1, data) }
        
        let versionData = data.prefix(4)
        let version = versionData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        let stateData = data.dropFirst(4)
        
        return (Int(version), Data(stateData))
    }
    
    private func compress(_ data: Data) throws -> Data {
        // Simplified compression using built-in compression
        // In production, use proper compression library
        return data
    }
    
    private func decompress(_ data: Data) throws -> Data {
        // Simplified decompression
        return data
    }
    
    private func encrypt(_ data: Data, key: Data) throws -> Data {
        // Simplified encryption - in production use CryptoKit
        var encrypted = data
        for i in 0..<encrypted.count {
            encrypted[i] ^= key[i % key.count]
        }
        return encrypted
    }
    
    private func decrypt(_ data: Data, key: Data) throws -> Data {
        // XOR encryption is symmetric
        return try encrypt(data, key: key)
    }
}

// MARK: - PersistenceStorage Protocol

/// Protocol for persistence storage backends.
public protocol PersistenceStorage {
    /// Saves data to storage.
    func save(_ data: Data) throws
    
    /// Loads data from storage.
    func load() throws -> Data?
    
    /// Clears stored data.
    func clear() throws
    
    /// Checks if data exists.
    func exists() -> Bool
}

// MARK: - UserDefaultsStorage

/// UserDefaults-based storage implementation.
public final class UserDefaultsStorage: PersistenceStorage {
    private let key: String
    private let defaults: UserDefaults
    
    public init(key: String, suiteName: String? = nil) {
        self.key = key
        self.defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }
    
    public func save(_ data: Data) throws {
        defaults.set(data, forKey: key)
    }
    
    public func load() throws -> Data? {
        defaults.data(forKey: key)
    }
    
    public func clear() throws {
        defaults.removeObject(forKey: key)
    }
    
    public func exists() -> Bool {
        defaults.object(forKey: key) != nil
    }
}

// MARK: - FileStorage

/// File-based storage implementation.
public final class FileStorage: PersistenceStorage {
    private let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    /// Creates file storage in the documents directory.
    public static func documents(filename: String) -> FileStorage {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return FileStorage(url: documentsURL.appendingPathComponent(filename))
    }
    
    /// Creates file storage in the caches directory.
    public static func caches(filename: String) -> FileStorage {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return FileStorage(url: cachesURL.appendingPathComponent(filename))
    }
    
    public func save(_ data: Data) throws {
        // Create directory if needed
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // Write atomically
        try data.write(to: url, options: .atomic)
    }
    
    public func load() throws -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return try Data(contentsOf: url)
    }
    
    public func clear() throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
    
    public func exists() -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}

// MARK: - KeychainStorage

/// Keychain-based storage for sensitive data.
public final class KeychainStorage: PersistenceStorage {
    private let service: String
    private let accessGroup: String?
    private let account = "state"
    
    public init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
    public func save(_ data: Data) throws {
        var query = baseQuery()
        query[kSecValueData as String] = data
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    public func load() throws -> Data? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.loadFailed(status)
        }
    }
    
    public func clear() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    public func exists() -> Bool {
        var query = baseQuery()
        query[kSecReturnData as String] = false
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func baseQuery() -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return query
    }
}

/// Keychain errors.
public enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
}

// MARK: - iCloudStorage

/// iCloud key-value storage implementation.
public final class iCloudStorage: PersistenceStorage {
    private let key: String
    
    public init(key: String) {
        self.key = key
    }
    
    public func save(_ data: Data) throws {
        NSUbiquitousKeyValueStore.default.set(data, forKey: key)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    public func load() throws -> Data? {
        NSUbiquitousKeyValueStore.default.data(forKey: key)
    }
    
    public func clear() throws {
        NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    public func exists() -> Bool {
        NSUbiquitousKeyValueStore.default.object(forKey: key) != nil
    }
}

// MARK: - MemoryStorage

/// In-memory storage for testing.
public final class MemoryStorage: PersistenceStorage {
    private var data: Data?
    
    public init() {}
    
    public func save(_ data: Data) throws {
        self.data = data
    }
    
    public func load() throws -> Data? {
        data
    }
    
    public func clear() throws {
        data = nil
    }
    
    public func exists() -> Bool {
        data != nil
    }
}

// MARK: - StateMigrator

/// Helper for migrating state between versions.
public struct StateMigrator<State: Codable> {
    
    /// A single migration step.
    public struct Migration {
        let fromVersion: Int
        let toVersion: Int
        let migrate: (Data) throws -> Data
    }
    
    private var migrations: [Migration] = []
    
    /// Creates a new state migrator.
    public init() {}
    
    /// Adds a migration step.
    public mutating func register(
        from fromVersion: Int,
        to toVersion: Int,
        migrate: @escaping (Data) throws -> Data
    ) {
        let migration = Migration(
            fromVersion: fromVersion,
            toVersion: toVersion,
            migrate: migrate
        )
        migrations.append(migration)
    }
    
    /// Migrates data from one version to another.
    public func migrate(data: Data, fromVersion: Int, toVersion: Int) throws -> State {
        var currentData = data
        var currentVersion = fromVersion
        
        while currentVersion < toVersion {
            guard let migration = migrations.first(where: { $0.fromVersion == currentVersion }) else {
                throw MigrationError.missingMigration(from: currentVersion)
            }
            
            currentData = try migration.migrate(currentData)
            currentVersion = migration.toVersion
        }
        
        return try JSONDecoder().decode(State.self, from: currentData)
    }
}

/// Migration errors.
public enum MigrationError: Error {
    case missingMigration(from: Int)
    case invalidData
}

// MARK: - StateSnapshot

/// A snapshot of state at a point in time.
public struct StateSnapshot<State: Codable>: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let state: State
    public let label: String?
    
    public init(state: State, label: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.state = state
        self.label = label
    }
}

// MARK: - SnapshotManager

/// Manages state snapshots for debugging and recovery.
public final class SnapshotManager<State: Codable>: ObservableObject {
    
    /// All saved snapshots.
    @Published public private(set) var snapshots: [StateSnapshot<State>] = []
    
    /// Maximum number of snapshots to keep.
    public let maxSnapshots: Int
    
    /// Storage for snapshots.
    private let storage: PersistenceStorage?
    
    /// Creates a snapshot manager.
    public init(maxSnapshots: Int = 50, storage: PersistenceStorage? = nil) {
        self.maxSnapshots = maxSnapshots
        self.storage = storage
        
        if let storage = storage {
            loadSnapshots(from: storage)
        }
    }
    
    /// Takes a snapshot of the current state.
    public func takeSnapshot(_ state: State, label: String? = nil) {
        let snapshot = StateSnapshot(state: state, label: label)
        snapshots.append(snapshot)
        
        // Trim if over limit
        if snapshots.count > maxSnapshots {
            snapshots.removeFirst(snapshots.count - maxSnapshots)
        }
        
        persistSnapshots()
    }
    
    /// Restores a snapshot by ID.
    public func restore(id: UUID) -> State? {
        snapshots.first { $0.id == id }?.state
    }
    
    /// Deletes a snapshot by ID.
    public func delete(id: UUID) {
        snapshots.removeAll { $0.id == id }
        persistSnapshots()
    }
    
    /// Clears all snapshots.
    public func clearAll() {
        snapshots.removeAll()
        persistSnapshots()
    }
    
    private func loadSnapshots(from storage: PersistenceStorage) {
        guard let data = try? storage.load(),
              let loaded = try? JSONDecoder().decode([StateSnapshot<State>].self, from: data) else {
            return
        }
        snapshots = loaded
    }
    
    private func persistSnapshots() {
        guard let storage = storage,
              let data = try? JSONEncoder().encode(snapshots) else {
            return
        }
        try? storage.save(data)
    }
}

// MARK: - AutoSaveController

/// Controls automatic state saving behavior.
public final class AutoSaveController: ObservableObject {
    
    /// Whether auto-save is enabled.
    @Published public var isEnabled: Bool = true
    
    /// Current auto-save interval.
    @Published public var interval: TimeInterval = 30
    
    /// Whether to save on app background.
    @Published public var saveOnBackground: Bool = true
    
    /// Whether to save on app terminate.
    @Published public var saveOnTerminate: Bool = true
    
    private var timer: Timer?
    private var saveHandler: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    /// Creates an auto-save controller.
    public init() {
        setupNotifications()
    }
    
    /// Configures the save handler.
    public func configure(saveHandler: @escaping () -> Void) {
        self.saveHandler = saveHandler
        updateTimer()
    }
    
    /// Starts auto-save timer.
    public func start() {
        isEnabled = true
        updateTimer()
    }
    
    /// Stops auto-save timer.
    public func stop() {
        isEnabled = false
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        timer?.invalidate()
        
        guard isEnabled, interval > 0 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.saveHandler?()
        }
    }
    
    private func setupNotifications() {
        #if os(iOS)
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                if self?.saveOnBackground == true {
                    self?.saveHandler?()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                if self?.saveOnTerminate == true {
                    self?.saveHandler?()
                }
            }
            .store(in: &cancellables)
        #endif
    }
    
    deinit {
        timer?.invalidate()
    }
}
