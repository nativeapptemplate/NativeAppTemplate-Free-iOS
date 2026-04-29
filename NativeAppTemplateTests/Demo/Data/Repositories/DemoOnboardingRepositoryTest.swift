//
//  DemoOnboardingRepositoryTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct DemoOnboardingRepositoryTest {
    @MainActor
    struct Tests {
        let repository = DemoOnboardingRepository()

        @Test
        func initialSetup() {
            repository.resetState()

            #expect(repository.onboardings.count == 5)
        }

        @Test
        func onboardingProperties() throws {
            repository.resetState()

            let onboarding1 = try #require(repository.onboardings.first { $0.id == 1 })
            #expect(onboarding1.imageOrientation == .portrait)

            let onboarding2 = try #require(repository.onboardings.first { $0.id == 2 })
            #expect(onboarding2.imageOrientation == .landscape)

            let onboarding3 = try #require(repository.onboardings.first { $0.id == 3 })
            #expect(onboarding3.imageOrientation == .portrait)
        }

        @Test
        func addOnboarding() throws {
            repository.resetState()

            let newOnboarding = Onboarding(id: 99, imageOrientation: .portrait)
            repository.addOnboarding(newOnboarding)

            #expect(repository.onboardings.count == 6)

            let addedOnboarding = try #require(repository.onboardings.first { $0.id == 99 })
            #expect(addedOnboarding.imageOrientation == .portrait)
        }

        @Test
        func clearOnboardings() {
            repository.resetState()

            #expect(repository.onboardings.count == 5)

            repository.clearOnboardings()

            #expect(repository.onboardings.isEmpty)
        }

        @Test
        func onboardingOrdering() {
            repository.resetState()

            let ids = repository.onboardings.map(\.id)
            #expect(ids == [1, 2, 3, 4, 5])

            let newOnboarding = Onboarding(id: 0, imageOrientation: .portrait)
            repository.addOnboarding(newOnboarding)

            let updatedIds = repository.onboardings.map(\.id)
            #expect(updatedIds == [1, 2, 3, 4, 5, 0])
        }

        @Test
        func onboardingIdentifiability() throws {
            repository.resetState()

            let ids = repository.onboardings.map(\.id)
            let uniqueIds = Set(ids)
            #expect(ids.count == uniqueIds.count)
        }

        @Test
        func onboardingHashability() throws {
            repository.resetState()

            let onboarding1 = try #require(repository.onboardings.first { $0.id == 1 })
            let onboarding2 = try #require(repository.onboardings.first { $0.id == 1 })
            let onboarding3 = try #require(repository.onboardings.first { $0.id == 2 })

            #expect(onboarding1 == onboarding2)
            #expect(onboarding1 != onboarding3)

            let onboardingSet: Set<Onboarding> = [onboarding1, onboarding2, onboarding3]
            #expect(onboardingSet.count == 2)
        }
    }
}
