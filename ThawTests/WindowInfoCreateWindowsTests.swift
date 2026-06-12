//
//  WindowInfoCreateWindowsTests.swift
//  Project: Thaw
//
//  Copyright (Ice) © 2023–2025 Jordan Baird
//  Copyright (Thaw) © 2026 Toni Förster
//  Licensed under the GNU GPLv3

import CoreGraphics
@testable import Thaw
import XCTest

/// Regression tests for `WindowInfo.createWindows(from:)` with an empty
/// identifier list.
///
/// An empty list is a valid, expected input — there are simply no windows
/// to describe. This happens routinely on macOS 26 and especially on
/// macOS 27, where the per-item menu bar window list is frequently empty.
/// `Bridging.createCGWindowArray(with:)` returns `nil` by design for an
/// empty list, so `createWindows(from:)` must short-circuit instead of
/// logging a misleading warning on every such call.
final class WindowInfoCreateWindowsTests: XCTestCase {
    private let emptyInputWarning = "createCGWindowArray returned nil"

    func testEmptyWindowIDsReturnsEmpty() {
        XCTAssertTrue(WindowInfo.createWindows(from: []).isEmpty)
    }

    func testEmptyWindowIDsDoesNotLogWarning() throws {
        let logger = DiagnosticLogger.shared
        let logFile = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("thaw-windowinfo-\(UUID().uuidString).log")

        logger.attachToFile(at: logFile)
        defer {
            logger.isEnabled = false
            try? FileManager.default.removeItem(at: logFile)
        }

        // Exercise the empty-input path that previously logged a warning.
        _ = WindowInfo.createWindows(from: [])

        // Emit a sentinel after the call. The logger's write queue is
        // serial and FIFO, so once the sentinel is visible in the file
        // any earlier write from createWindows has already been flushed.
        let sentinel = "windowinfo-sentinel-\(UUID().uuidString)"
        logger.log(level: .info, category: "Test", message: sentinel)

        let contents = try pollForFileContents(at: logFile, containing: sentinel)
        XCTAssertFalse(
            contents.contains(emptyInputWarning),
            "createWindows(from: []) must not log a warning for empty input"
        )
    }

    // MARK: - Helpers

    /// Polls the file at `url` until it contains `needle` or the timeout
    /// elapses, then returns the file's contents. Used to wait for the
    /// asynchronous diagnostic-log write queue to flush.
    private func pollForFileContents(
        at url: URL,
        containing needle: String,
        timeout: TimeInterval = 2
    ) throws -> String {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let contents = try? String(contentsOf: url, encoding: .utf8),
               contents.contains(needle)
            {
                return contents
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }
}
