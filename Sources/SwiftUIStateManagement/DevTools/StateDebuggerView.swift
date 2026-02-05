import SwiftUI

// MARK: - State Debugger View

/// A comprehensive visual debugger for state management.
/// Provides real-time state inspection, time-travel, and performance monitoring.
///
/// Usage:
/// ```swift
/// struct ContentView: View {
///     @ObservedObject var store: Store<AppState, AppAction>
///
///     var body: some View {
///         VStack {
///             // Your app content
///         }
///         .debuggerOverlay(store: store)
///     }
/// }
/// ```
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct StateDebuggerView<State, Action>: View {
    
    @ObservedObject private var store: Store<State, Action>
    @State private var selectedTab: DebuggerTab = .state
    @State private var isExpanded = true
    @State private var searchText = ""
    @State private var selectedSnapshot: Int?
    
    public enum DebuggerTab: String, CaseIterable {
        case state = "State"
        case actions = "Actions"
        case timeline = "Timeline"
        case performance = "Performance"
    }
    
    public init(store: Store<State, Action>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if isExpanded {
                tabBar
                
                TabView(selection: $selectedTab) {
                    stateInspector
                        .tag(DebuggerTab.state)
                    
                    actionList
                        .tag(DebuggerTab.actions)
                    
                    timelineView
                        .tag(DebuggerTab.timeline)
                    
                    performanceView
                        .tag(DebuggerTab.performance)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
            }
        }
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Image(systemName: "ladybug.fill")
                .foregroundColor(.orange)
            
            Text("State Debugger")
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 12) {
                // Effect indicator
                if store.isProcessingEffects {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("\(store.activeEffectCount)")
                            .font(.caption)
                    }
                }
                
                // Dispatch count
                Text("Actions: \(store.dispatchCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Collapse button
                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(DebuggerTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation { selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(.caption)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedTab == tab ? Color.orange.opacity(0.2) : Color.clear)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - State Inspector
    
    private var stateInspector: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search state...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    StateTreeView(value: store.state, label: "State", searchText: searchText)
                }
                .padding()
            }
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Action List
    
    private var actionList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(store.snapshots.reversed()) { snapshot in
                        if let action = snapshot.action {
                            ActionRowView(
                                action: String(describing: action),
                                timestamp: snapshot.timestamp,
                                index: snapshot.dispatchIndex,
                                isSelected: selectedSnapshot == snapshot.dispatchIndex
                            )
                            .onTapGesture {
                                selectedSnapshot = snapshot.dispatchIndex
                                store.timeTravel(to: store.snapshots.firstIndex(where: { $0.id == snapshot.id }) ?? 0)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Timeline View
    
    private var timelineView: some View {
        VStack(spacing: 16) {
            // Time travel controls
            HStack(spacing: 20) {
                Button {
                    store.goToStart()
                } label: {
                    Image(systemName: "backward.end.fill")
                }
                .disabled(store.currentHistoryIndex == 0)
                
                Button {
                    store.stepBack()
                } label: {
                    Image(systemName: "backward.fill")
                }
                .disabled(store.currentHistoryIndex == 0)
                
                Text("\(store.currentHistoryIndex + 1) / \(store.historyCount)")
                    .font(.caption.monospacedDigit())
                    .frame(minWidth: 60)
                
                Button {
                    store.stepForward()
                } label: {
                    Image(systemName: "forward.fill")
                }
                .disabled(store.currentHistoryIndex >= store.historyCount - 1)
                
                Button {
                    store.goToEnd()
                } label: {
                    Image(systemName: "forward.end.fill")
                }
                .disabled(store.currentHistoryIndex >= store.historyCount - 1)
            }
            .font(.title3)
            
            // Timeline slider
            if store.historyCount > 1 {
                Slider(
                    value: Binding(
                        get: { Double(store.currentHistoryIndex) },
                        set: { store.timeTravel(to: Int($0)) }
                    ),
                    in: 0...Double(max(0, store.historyCount - 1)),
                    step: 1
                )
                .padding(.horizontal)
            }
            
            // Current snapshot info
            if let snapshot = store.snapshots[safe: store.currentHistoryIndex] {
                VStack(alignment: .leading, spacing: 4) {
                    if let action = snapshot.action {
                        Text("Action: \(String(describing: action))")
                            .font(.caption)
                    }
                    Text("Time: \(snapshot.timestamp.formatted(date: .omitted, time: .standard))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxHeight: 300)
    }
    
    // MARK: - Performance View
    
    private var performanceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(title: "Total Actions", value: "\(store.dispatchCount)")
                StatCard(title: "Effects Run", value: "\(store.effectCount)")
                StatCard(title: "History Size", value: "\(store.historyCount)")
                StatCard(title: "Active Effects", value: "\(store.activeEffectCount)")
            }
            
            if let lastTime = store.lastDispatchTime {
                Text("Last action: \(lastTime.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Actions
            HStack {
                Button("Clear History") {
                    store.clearHistory()
                }
                .buttonStyle(.bordered)
                
                Button("Cancel Effects") {
                    store.cancelAllEffects()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .frame(maxHeight: 300)
    }
}

// MARK: - State Tree View

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct StateTreeView: View {
    let value: Any
    let label: String
    let searchText: String
    let depth: Int
    
    @State private var isExpanded = true
    
    init(value: Any, label: String, searchText: String = "", depth: Int = 0) {
        self.value = value
        self.label = label
        self.searchText = searchText
        self.depth = depth
    }
    
    var body: some View {
        let mirror = Mirror(reflecting: value)
        let hasChildren = !mirror.children.isEmpty
        
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                if hasChildren {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            withAnimation { isExpanded.toggle() }
                        }
                } else {
                    Spacer()
                        .frame(width: 12)
                }
                
                Text(label)
                    .font(.caption.monospaced())
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                if !hasChildren {
                    Text(":")
                        .font(.caption.monospaced())
                        .foregroundColor(.secondary)
                    
                    Text(String(describing: value))
                        .font(.caption.monospaced())
                        .foregroundColor(colorForValue(value))
                        .lineLimit(1)
                }
            }
            .padding(.leading, CGFloat(depth * 16))
            .background(matchesSearch ? Color.yellow.opacity(0.3) : Color.clear)
            
            if hasChildren && isExpanded {
                ForEach(Array(mirror.children.enumerated()), id: \.offset) { index, child in
                    StateTreeView(
                        value: child.value,
                        label: child.label ?? "[\(index)]",
                        searchText: searchText,
                        depth: depth + 1
                    )
                }
            }
        }
    }
    
    private var matchesSearch: Bool {
        guard !searchText.isEmpty else { return false }
        return label.localizedCaseInsensitiveContains(searchText) ||
               String(describing: value).localizedCaseInsensitiveContains(searchText)
    }
    
    private func colorForValue(_ value: Any) -> Color {
        switch value {
        case is Bool: return .purple
        case is any Numeric: return .orange
        case is String: return .green
        case is Date: return .cyan
        default: return .primary
        }
    }
}

// MARK: - Action Row View

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct ActionRowView: View {
    let action: String
    let timestamp: Date
    let index: Int
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text("#\(index)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
            
            Text(action)
                .font(.caption.monospaced())
                .lineLimit(1)
            
            Spacer()
            
            Text(timestamp.formatted(date: .omitted, time: .standard))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isSelected ? Color.orange.opacity(0.2) : Color.secondary.opacity(0.05))
        .cornerRadius(4)
    }
}

// MARK: - Stat Card

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.monospacedDigit())
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

// MARK: - View Modifier

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct DebuggerOverlayModifier<State, Action>: ViewModifier {
    let store: Store<State, Action>
    let alignment: Alignment
    
    @State private var isVisible = false
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if isVisible {
                    StateDebuggerView(store: store)
                        .frame(maxWidth: 400)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    withAnimation { isVisible.toggle() }
                } label: {
                    Image(systemName: "ladybug.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {
    /// Adds a debugger overlay to the view.
    public func debuggerOverlay<State, Action>(
        store: Store<State, Action>,
        alignment: Alignment = .bottom
    ) -> some View {
        modifier(DebuggerOverlayModifier(store: store, alignment: alignment))
    }
}
