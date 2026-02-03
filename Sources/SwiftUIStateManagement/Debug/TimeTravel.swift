// TimeTravel.swift
// SwiftUI-State-Management
//
// Time-travel debugging for state management.
// Record, playback, and jump to any point in state history.

import Foundation
import Combine
import SwiftUI

// MARK: - TimeTravelDebugger

/// A comprehensive time-travel debugging system for state management.
///
/// `TimeTravelDebugger` provides:
/// - Complete action and state history recording
/// - Jump to any point in history
/// - Playback with configurable speed
/// - State diffing and inspection
/// - Export/import of debug sessions
///
/// Example usage:
/// ```swift
/// let debugger = TimeTravelDebugger<AppState, AppAction>()
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     middlewares: [debugger.middleware()]
/// )
///
/// // Jump to a previous state
/// debugger.jumpTo(index: 5)
///
/// // Start playback
/// debugger.play()
/// ```
public final class TimeTravelDebugger<State, Action>: ObservableObject {
    
    // MARK: - Types
    
    /// A single entry in the state history.
    public struct HistoryEntry: Identifiable {
        public let id: UUID
        public let index: Int
        public let timestamp: Date
        public let action: Action
        public let stateBefore: State
        public let stateAfter: State
        public let duration: TimeInterval
        public let metadata: [String: Any]
        
        public init(
            index: Int,
            timestamp: Date = Date(),
            action: Action,
            stateBefore: State,
            stateAfter: State,
            duration: TimeInterval = 0,
            metadata: [String: Any] = [:]
        ) {
            self.id = UUID()
            self.index = index
            self.timestamp = timestamp
            self.action = action
            self.stateBefore = stateBefore
            self.stateAfter = stateAfter
            self.duration = duration
            self.metadata = metadata
        }
    }
    
    /// Playback state.
    public enum PlaybackState: Equatable {
        case idle
        case playing
        case paused
        case recording
    }
    
    /// Configuration for the time-travel debugger.
    public struct Configuration {
        /// Maximum number of history entries to keep.
        public var maxHistorySize: Int
        
        /// Whether to record by default.
        public var recordByDefault: Bool
        
        /// Playback speed (1.0 = real-time).
        public var playbackSpeed: Double
        
        /// Whether to pause on errors.
        public var pauseOnError: Bool
        
        /// Actions to exclude from recording.
        public var excludedActions: Set<String>
        
        /// Whether to capture stack traces.
        public var captureStackTraces: Bool
        
        public init(
            maxHistorySize: Int = 1000,
            recordByDefault: Bool = true,
            playbackSpeed: Double = 1.0,
            pauseOnError: Bool = true,
            excludedActions: Set<String> = [],
            captureStackTraces: Bool = false
        ) {
            self.maxHistorySize = maxHistorySize
            self.recordByDefault = recordByDefault
            self.playbackSpeed = playbackSpeed
            self.pauseOnError = pauseOnError
            self.excludedActions = excludedActions
            self.captureStackTraces = captureStackTraces
        }
        
        public static let `default` = Configuration()
    }
    
    // MARK: - Properties
    
    /// Current configuration.
    public let configuration: Configuration
    
    /// Complete history of state changes.
    @Published public private(set) var history: [HistoryEntry] = []
    
    /// Current position in history.
    @Published public private(set) var currentIndex: Int = -1
    
    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle
    
    /// Whether recording is enabled.
    @Published public var isRecording: Bool = true
    
    /// Current state (at current index).
    public var currentState: State? {
        guard currentIndex >= 0, currentIndex < history.count else { return nil }
        return history[currentIndex].stateAfter
    }
    
    /// Whether we can go back in history.
    public var canGoBack: Bool {
        currentIndex > 0
    }
    
    /// Whether we can go forward in history.
    public var canGoForward: Bool {
        currentIndex < history.count - 1
    }
    
    /// Total number of recorded entries.
    public var entryCount: Int {
        history.count
    }
    
    /// Handler for state restoration.
    public var restoreHandler: ((State) -> Void)?
    
    /// Handler for action replay.
    public var replayHandler: ((Action) -> Void)?
    
    private var playbackTimer: Timer?
    private var playbackIndex: Int = 0
    private let queue = DispatchQueue(label: "com.statemanagement.timetravel")
    
    // MARK: - Initialization
    
    /// Creates a new time-travel debugger.
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.isRecording = configuration.recordByDefault
    }
    
    // MARK: - Recording
    
    /// Records a state change.
    public func record(
        action: Action,
        stateBefore: State,
        stateAfter: State,
        duration: TimeInterval = 0,
        metadata: [String: Any] = [:]
    ) {
        guard isRecording else { return }
        
        let actionName = String(describing: type(of: action))
        guard !configuration.excludedActions.contains(actionName) else { return }
        
        // If we're not at the end of history, truncate forward history
        if currentIndex < history.count - 1 {
            history = Array(history.prefix(currentIndex + 1))
        }
        
        let entry = HistoryEntry(
            index: history.count,
            action: action,
            stateBefore: stateBefore,
            stateAfter: stateAfter,
            duration: duration,
            metadata: metadata
        )
        
        history.append(entry)
        currentIndex = history.count - 1
        
        // Trim if over limit
        if history.count > configuration.maxHistorySize {
            let excess = history.count - configuration.maxHistorySize
            history.removeFirst(excess)
            currentIndex -= excess
        }
    }
    
    /// Clears all history.
    public func clearHistory() {
        history.removeAll()
        currentIndex = -1
    }
    
    // MARK: - Navigation
    
    /// Jumps to a specific index in history.
    public func jumpTo(index: Int) {
        guard index >= 0 && index < history.count else { return }
        
        currentIndex = index
        
        if let state = currentState {
            restoreHandler?(state)
        }
    }
    
    /// Goes back one step in history.
    public func goBack() {
        guard canGoBack else { return }
        jumpTo(index: currentIndex - 1)
    }
    
    /// Goes forward one step in history.
    public func goForward() {
        guard canGoForward else { return }
        jumpTo(index: currentIndex + 1)
    }
    
    /// Jumps to the beginning of history.
    public func jumpToStart() {
        jumpTo(index: 0)
    }
    
    /// Jumps to the end of history.
    public func jumpToEnd() {
        jumpTo(index: history.count - 1)
    }
    
    /// Jumps to the entry before a specific timestamp.
    public func jumpToTime(_ date: Date) {
        guard let index = history.lastIndex(where: { $0.timestamp <= date }) else { return }
        jumpTo(index: index)
    }
    
    // MARK: - Playback
    
    /// Starts playback from the current position.
    public func play() {
        guard !history.isEmpty else { return }
        
        playbackState = .playing
        playbackIndex = max(0, currentIndex)
        
        scheduleNextPlayback()
    }
    
    /// Pauses playback.
    public func pause() {
        playbackState = .paused
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    /// Stops playback and returns to recording mode.
    public func stop() {
        playbackState = .idle
        playbackTimer?.invalidate()
        playbackTimer = nil
        playbackIndex = 0
    }
    
    /// Toggles between play and pause.
    public func togglePlayback() {
        switch playbackState {
        case .idle:
            play()
        case .playing:
            pause()
        case .paused:
            play()
        case .recording:
            break
        }
    }
    
    private func scheduleNextPlayback() {
        guard playbackState == .playing else { return }
        guard playbackIndex < history.count else {
            stop()
            return
        }
        
        let entry = history[playbackIndex]
        let delay = entry.duration / configuration.playbackSpeed
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: max(0.01, delay), repeats: false) { [weak self] _ in
            self?.playbackStep()
        }
    }
    
    private func playbackStep() {
        guard playbackState == .playing else { return }
        guard playbackIndex < history.count else {
            stop()
            return
        }
        
        jumpTo(index: playbackIndex)
        playbackIndex += 1
        
        scheduleNextPlayback()
    }
    
    /// Steps forward one action during playback.
    public func stepForward() {
        guard canGoForward else { return }
        goForward()
    }
    
    /// Steps backward one action during playback.
    public func stepBackward() {
        guard canGoBack else { return }
        goBack()
    }
    
    // MARK: - Replay
    
    /// Replays all actions from the beginning.
    public func replayAll() {
        guard let handler = replayHandler else { return }
        
        for entry in history {
            handler(entry.action)
        }
    }
    
    /// Replays actions from a specific index.
    public func replay(from startIndex: Int) {
        guard let handler = replayHandler else { return }
        guard startIndex >= 0 && startIndex < history.count else { return }
        
        for entry in history.dropFirst(startIndex) {
            handler(entry.action)
        }
    }
    
    // MARK: - Middleware
    
    /// Creates a middleware that records to this debugger.
    public func middleware() -> TimeTravelMiddleware<State, Action> {
        TimeTravelMiddleware(debugger: self)
    }
    
    // MARK: - Export/Import
    
    /// Exports history to JSON data.
    public func exportHistory() -> Data? where State: Encodable, Action: Encodable {
        let exportable = history.map { entry -> ExportableEntry in
            ExportableEntry(
                index: entry.index,
                timestamp: entry.timestamp,
                action: entry.action,
                stateAfter: entry.stateAfter,
                duration: entry.duration
            )
        }
        
        return try? JSONEncoder().encode(exportable)
    }
    
    /// Imports history from JSON data.
    public func importHistory(_ data: Data) throws where State: Decodable, Action: Decodable {
        let decoded = try JSONDecoder().decode([ExportableEntry].self, from: data)
        
        history = decoded.enumerated().map { index, entry in
            HistoryEntry(
                index: index,
                timestamp: entry.timestamp,
                action: entry.action,
                stateBefore: entry.stateAfter, // Simplified
                stateAfter: entry.stateAfter,
                duration: entry.duration
            )
        }
        
        currentIndex = history.isEmpty ? -1 : history.count - 1
    }
    
    private struct ExportableEntry: Codable where State: Codable, Action: Codable {
        let index: Int
        let timestamp: Date
        let action: Action
        let stateAfter: State
        let duration: TimeInterval
    }
}

// MARK: - TimeTravelMiddleware

/// Middleware that records state changes to a time-travel debugger.
public struct TimeTravelMiddleware<State, Action>: Middleware {
    
    private weak var debugger: TimeTravelDebugger<State, Action>?
    
    public init(debugger: TimeTravelDebugger<State, Action>) {
        self.debugger = debugger
    }
    
    public func handle(
        action: Action,
        state: State,
        next: (Action) -> Effect<Action>
    ) -> Effect<Action> {
        let startTime = Date()
        let stateBefore = state
        
        let effect = next(action)
        
        let duration = Date().timeIntervalSince(startTime)
        
        debugger?.record(
            action: action,
            stateBefore: stateBefore,
            stateAfter: state,
            duration: duration
        )
        
        return effect
    }
}

// MARK: - StateInspector

/// Provides tools for inspecting and comparing states.
public struct StateInspector<State> {
    
    /// Computes a diff between two states.
    public static func diff(
        from oldState: State,
        to newState: State
    ) -> StateDiff where State: Equatable {
        let oldMirror = Mirror(reflecting: oldState)
        let newMirror = Mirror(reflecting: newState)
        
        var changes: [StateDiff.Change] = []
        
        for (oldChild, newChild) in zip(oldMirror.children, newMirror.children) {
            guard let label = oldChild.label else { continue }
            
            let oldValue = String(describing: oldChild.value)
            let newValue = String(describing: newChild.value)
            
            if oldValue != newValue {
                changes.append(StateDiff.Change(
                    path: label,
                    oldValue: oldValue,
                    newValue: newValue
                ))
            }
        }
        
        return StateDiff(changes: changes)
    }
    
    /// Creates a formatted string representation of a state.
    public static func format(_ state: State, indent: Int = 2) -> String {
        formatValue(state, level: 0, indent: indent)
    }
    
    private static func formatValue(_ value: Any, level: Int, indent: Int) -> String {
        let padding = String(repeating: " ", count: level * indent)
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return "\(padding)\(value)"
        }
        
        var lines: [String] = []
        lines.append("\(padding){")
        
        for child in mirror.children {
            let label = child.label ?? "?"
            let childValue = formatValue(child.value, level: level + 1, indent: indent)
            lines.append("\(padding)  \(label): \(childValue.trimmingCharacters(in: .whitespaces))")
        }
        
        lines.append("\(padding)}")
        
        return lines.joined(separator: "\n")
    }
}

/// Represents differences between two states.
public struct StateDiff {
    /// A single property change.
    public struct Change {
        public let path: String
        public let oldValue: String
        public let newValue: String
    }
    
    /// All changes.
    public let changes: [Change]
    
    /// Whether there are any changes.
    public var hasChanges: Bool {
        !changes.isEmpty
    }
    
    /// Number of changes.
    public var changeCount: Int {
        changes.count
    }
    
    /// Formatted description of changes.
    public var description: String {
        guard hasChanges else { return "No changes" }
        
        return changes.map { change in
            "\(change.path): \(change.oldValue) → \(change.newValue)"
        }.joined(separator: "\n")
    }
}

// MARK: - HistoryBrowser

/// A browsable view of state history.
public struct HistoryBrowser<State, Action>: View {
    
    @ObservedObject var debugger: TimeTravelDebugger<State, Action>
    
    public init(debugger: TimeTravelDebugger<State, Action>) {
        self.debugger = debugger
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbar
            
            Divider()
            
            // Timeline
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(debugger.history) { entry in
                        entryRow(entry)
                    }
                }
            }
            
            Divider()
            
            // Playback controls
            playbackControls
        }
    }
    
    private var toolbar: some View {
        HStack {
            Text("History")
                .font(.headline)
            
            Spacer()
            
            Text("\(debugger.entryCount) entries")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { debugger.clearHistory() }) {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    private func entryRow(_ entry: TimeTravelDebugger<State, Action>.HistoryEntry) -> some View {
        HStack {
            Circle()
                .fill(entry.index == debugger.currentIndex ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading) {
                Text(String(describing: type(of: entry.action)))
                    .font(.system(.body, design: .monospaced))
                
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.1fms", entry.duration * 1000))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(entry.index == debugger.currentIndex ? Color.blue.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            debugger.jumpTo(index: entry.index)
        }
    }
    
    private var playbackControls: some View {
        HStack(spacing: 20) {
            Button(action: { debugger.jumpToStart() }) {
                Image(systemName: "backward.end.fill")
            }
            .disabled(!debugger.canGoBack)
            
            Button(action: { debugger.stepBackward() }) {
                Image(systemName: "backward.frame.fill")
            }
            .disabled(!debugger.canGoBack)
            
            Button(action: { debugger.togglePlayback() }) {
                Image(systemName: debugger.playbackState == .playing ? "pause.fill" : "play.fill")
            }
            
            Button(action: { debugger.stepForward() }) {
                Image(systemName: "forward.frame.fill")
            }
            .disabled(!debugger.canGoForward)
            
            Button(action: { debugger.jumpToEnd() }) {
                Image(systemName: "forward.end.fill")
            }
            .disabled(!debugger.canGoForward)
        }
        .font(.title2)
        .padding()
    }
}

// MARK: - DebugSession

/// Represents a complete debugging session.
public struct DebugSession<State, Action>: Identifiable, Codable where State: Codable, Action: Codable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let history: [DebugSessionEntry<State, Action>]
    
    public init(
        name: String,
        history: [DebugSessionEntry<State, Action>]
    ) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.history = history
    }
}

/// An entry in a debug session.
public struct DebugSessionEntry<State: Codable, Action: Codable>: Codable {
    public let timestamp: Date
    public let action: Action
    public let state: State
    public let duration: TimeInterval
}

// MARK: - SessionManager

/// Manages saved debugging sessions.
public final class SessionManager<State: Codable, Action: Codable>: ObservableObject {
    
    /// All saved sessions.
    @Published public private(set) var sessions: [DebugSession<State, Action>] = []
    
    /// Storage URL.
    private let storageURL: URL
    
    /// Creates a session manager.
    public init(storageDirectory: URL? = nil) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storageURL = storageDirectory ?? documentsURL.appendingPathComponent("debug_sessions")
        
        loadSessions()
    }
    
    /// Saves the current debugger state as a session.
    public func saveSession(
        name: String,
        from debugger: TimeTravelDebugger<State, Action>
    ) {
        let entries = debugger.history.map { entry in
            DebugSessionEntry(
                timestamp: entry.timestamp,
                action: entry.action,
                state: entry.stateAfter,
                duration: entry.duration
            )
        }
        
        let session = DebugSession(name: name, history: entries)
        sessions.append(session)
        
        persistSessions()
    }
    
    /// Loads a session into a debugger.
    public func loadSession(
        _ session: DebugSession<State, Action>,
        into debugger: TimeTravelDebugger<State, Action>
    ) {
        debugger.clearHistory()
        
        for entry in session.history {
            debugger.record(
                action: entry.action,
                stateBefore: entry.state,
                stateAfter: entry.state,
                duration: entry.duration
            )
        }
    }
    
    /// Deletes a session.
    public func deleteSession(_ session: DebugSession<State, Action>) {
        sessions.removeAll { $0.id == session.id }
        persistSessions()
    }
    
    private func loadSessions() {
        let decoder = JSONDecoder()
        
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: nil)
            
            for file in files where file.pathExtension == "json" {
                let data = try Data(contentsOf: file)
                let session = try decoder.decode(DebugSession<State, Action>.self, from: data)
                sessions.append(session)
            }
        } catch {
            print("Failed to load sessions: \(error)")
        }
    }
    
    private func persistSessions() {
        let encoder = JSONEncoder()
        
        do {
            try FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
            
            for session in sessions {
                let fileURL = storageURL.appendingPathComponent("\(session.id.uuidString).json")
                let data = try encoder.encode(session)
                try data.write(to: fileURL)
            }
        } catch {
            print("Failed to persist sessions: \(error)")
        }
    }
}

// MARK: - Bookmarks

/// Manages bookmarks in state history.
public final class BookmarkManager<State, Action>: ObservableObject {
    
    /// A bookmark entry.
    public struct Bookmark: Identifiable {
        public let id: UUID
        public let historyIndex: Int
        public let name: String
        public let description: String?
        public let createdAt: Date
    }
    
    /// All bookmarks.
    @Published public private(set) var bookmarks: [Bookmark] = []
    
    /// Creates a bookmark manager.
    public init() {}
    
    /// Adds a bookmark at the current position.
    public func addBookmark(
        at index: Int,
        name: String,
        description: String? = nil
    ) {
        let bookmark = Bookmark(
            id: UUID(),
            historyIndex: index,
            name: name,
            description: description,
            createdAt: Date()
        )
        
        bookmarks.append(bookmark)
    }
    
    /// Removes a bookmark.
    public func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
    }
    
    /// Clears all bookmarks.
    public func clearAll() {
        bookmarks.removeAll()
    }
}
