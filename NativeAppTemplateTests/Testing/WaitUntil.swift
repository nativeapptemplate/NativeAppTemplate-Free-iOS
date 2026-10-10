//
//  WaitUntil.swift
//  NativeAppTemplate
//

import Testing

/// Polls `condition` until it returns `true`, recording a test issue if `timeout` elapses first.
///
/// View models start their work in an unstructured `Task`, so tests cannot `await` it directly.
/// Waiting for the observable result instead of a fixed `Task.sleep` keeps tests fast locally
/// and stops them from failing on slow CI runners.
///
/// The timeout is generous on purpose: it only matters when a test is about to fail, and on a
/// busy CI runner a main-actor task can wait about 10 seconds to be scheduled.
@MainActor
func waitUntil(
    timeout: Duration = .seconds(60),
    sourceLocation: SourceLocation = #_sourceLocation,
    _ condition: () -> Bool
) async {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)

    while !condition() {
        guard clock.now < deadline else {
            Issue.record("Condition not met within \(timeout)", sourceLocation: sourceLocation)
            return
        }
        try? await Task.sleep(for: .milliseconds(10))
    }
}
