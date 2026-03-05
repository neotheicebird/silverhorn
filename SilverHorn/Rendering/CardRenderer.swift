// CardRenderer.swift
// Renders card HTML into UIImage snapshots via an off-screen WKWebView.
//
// RENDERING PIPELINE (spec §14, design.md §3, §4):
//   HTML string → WKWebView (off-screen) → takeSnapshot → UIImage
//
// CONCURRENCY MODEL:
// WKWebView must live on the main thread. Renders are serialised through
// a single off-screen WebView to avoid creating/destroying views per card.
// A DispatchWorkItem cancellation pattern implements the 300ms debounce (spec §16).
//
// CACHE:
// Rendered images are stored in `cache` keyed by card UUID.
// Callers (AppState) set images on their CardModel when the callback fires.
// Cache is keyed by UUID so a single-card re-render is cheap.
//
// SNAPSHOT SCALE:
// WKSnapshotConfiguration.snapshotWidth = cardWidthPt (540) produces a
// snapshot at screen scale (@2x on most iPhones → 1080px wide, 1350px tall).

import UIKit
import WebKit

@MainActor
final class CardRenderer: NSObject {

    // MARK: - Singleton
    // One renderer shared across the app. WKWebView is expensive to create;
    // reusing a single instance for sequential renders is the right trade-off.
    static let shared = CardRenderer()

    // MARK: - Private State

    /// Off-screen WebView used for all renders. Sized to the logical card dimensions.
    private let webView: WKWebView

    /// In-memory render cache keyed by card UUID. Cleared on memory warning.
    private(set) var cache: [UUID: UIImage] = [:]

    /// Queue of pending render jobs. Jobs are dequeued one at a time.
    private var renderQueue: [(id: UUID, html: String, completion: (UUID, UIImage) -> Void)] = []

    /// True while a render is in flight. Prevents concurrent WebView loads.
    private var isRendering = false

    /// The pending debounce work item. Cancelled and replaced on rapid state changes.
    private var debounceWork: DispatchWorkItem?

    /// Debounce interval (spec §16).
    private let debounceInterval: TimeInterval = 0.3

    // MARK: - Init

    private override init() {
        // Configure WKWebView with a frame matching the logical card size.
        // It is added off-screen (negative origin) so it never appears in the UI.
        let config = WKWebViewConfiguration()
        let frame  = CGRect(
            x: -HTMLTemplateBuilder.cardWidthPt - 1,
            y: 0,
            width:  HTMLTemplateBuilder.cardWidthPt,
            height: HTMLTemplateBuilder.cardHeightPt
        )
        webView = WKWebView(frame: frame, configuration: config)

        super.init()

        webView.navigationDelegate = self

        // Add to the key window's view hierarchy off-screen.
        // WKWebView requires a window to render; without this, snapshots are blank.
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            window.addSubview(webView)
        }

        // Release cache under memory pressure.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    // MARK: - Public API

    /// Schedules a re-render of the given cards after the debounce interval.
    /// Cancels any previously scheduled debounce, so rapid calls coalesce.
    /// - Parameters:
    ///   - cards: The cards to render (their UUIDs are used to key the cache).
    ///   - theme: Current theme.
    ///   - font: Current font.
    ///   - multiplier: Current font size multiplier.
    ///   - completion: Called on the main thread with each card's UUID + UIImage.
    func scheduleRender(
        cards: [CardModel],
        theme: ThemeModel,
        font: FontModel,
        multiplier: Double,
        completion: @escaping (UUID, UIImage) -> Void
    ) {
        // Cancel the previous debounce work item (spec §16).
        debounceWork?.cancel()

        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.enqueueRenders(cards: cards, theme: theme, font: font, multiplier: multiplier, completion: completion)
        }
        debounceWork = work

        // Schedule after the debounce interval on the main queue.
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }

    /// Invalidates the cached image for a single card UUID.
    /// Call this when a card's text is edited so only that card re-renders.
    func invalidate(id: UUID) {
        cache.removeValue(forKey: id)
    }

    /// Invalidates all cached images (e.g. theme or font change).
    func invalidateAll() {
        cache.removeAll()
    }

    // MARK: - Render Queue

    private func enqueueRenders(
        cards: [CardModel],
        theme: ThemeModel,
        font: FontModel,
        multiplier: Double,
        completion: @escaping (UUID, UIImage) -> Void
    ) {
        for card in cards {
            // Skip if we already have a valid cached image for this card.
            if cache[card.id] != nil { continue }

            let html = HTMLTemplateBuilder.build(
                text: card.text,
                theme: theme,
                font: font,
                fontSizeMultiplier: multiplier
            )
            renderQueue.append((id: card.id, html: html, completion: completion))
        }
        drainQueue()
    }

    /// Starts the next render job if none is in flight.
    private func drainQueue() {
        guard !isRendering, let job = renderQueue.first else { return }
        isRendering = true
        // Load the HTML string — navigationDelegate.didFinish fires when ready.
        webView.loadHTMLString(job.html, baseURL: nil)
    }

    // MARK: - Snapshot

    /// Takes a WKWebView snapshot after navigation completes.
    private func takeSnapshot(for job: (id: UUID, html: String, completion: (UUID, UIImage) -> Void)) {
        let config = WKSnapshotConfiguration()
        // Setting snapshotWidth to the logical card width causes WKWebView
        // to produce a snapshot at screen scale (@2x → 1080px wide output).
        config.snapshotWidth = HTMLTemplateBuilder.cardWidthPt as NSNumber

        webView.takeSnapshot(with: config) { [weak self] image, error in
            guard let self, let image else {
                self?.finishJob()
                return
            }
            // Store in cache and notify the caller.
            self.cache[job.id] = image
            job.completion(job.id, image)
            self.finishJob()
        }
    }

    /// Removes the completed job from the queue and processes the next one.
    private func finishJob() {
        if !renderQueue.isEmpty { renderQueue.removeFirst() }
        isRendering = false
        drainQueue()
    }

    // MARK: - Cache Management

    @objc private func clearCache() {
        cache.removeAll()
    }
}

// MARK: - WKNavigationDelegate

extension CardRenderer: WKNavigationDelegate {

    /// Called when WKWebView finishes loading + running the page's JavaScript.
    /// This is the correct moment to take the snapshot — the font scaling JS
    /// in card.html has already run by the time this fires.
    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            guard let job = self.renderQueue.first else { return }
            self.takeSnapshot(for: job)
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in self.finishJob() }
    }

    nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in self.finishJob() }
    }
}
