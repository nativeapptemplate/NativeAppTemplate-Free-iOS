//
//  WaitUntilTest.swift
//  NativeAppTemplate
//

import Testing

@MainActor
@Suite
struct WaitUntilTest {
    final class Flag {
        var isSet = false
    }

    @Test
    func returnsOnceConditionBecomesTrue() async {
        let flag = Flag()
        Task {
            try? await Task.sleep(for: .milliseconds(30))
            flag.isSet = true
        }

        await waitUntil { flag.isSet }

        #expect(flag.isSet)
    }

    @Test
    func recordsIssueWhenConditionNeverBecomesTrue() async {
        await withKnownIssue {
            await waitUntil(timeout: .milliseconds(50)) { false }
        }
    }
}
