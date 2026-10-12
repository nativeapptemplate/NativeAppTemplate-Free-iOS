//
//  TestGate.swift
//  NativeAppTemplate
//

/// Holds a test double's call in flight until the test opens it, so the test can
/// check a view model's busy state while the work is still running.
///
///     repository.gate = TestGate()
///     viewModel.save()
///     await waitUntil { repository.gate!.isWaiting }
///     #expect(viewModel.isBusy)
///     repository.gate!.open()
@MainActor
final class TestGate {
    private var continuation: CheckedContinuation<Void, Never>?
    private(set) var isWaiting = false

    func wait() async {
        isWaiting = true
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        isWaiting = false
        continuation?.resume()
        continuation = nil
    }
}
