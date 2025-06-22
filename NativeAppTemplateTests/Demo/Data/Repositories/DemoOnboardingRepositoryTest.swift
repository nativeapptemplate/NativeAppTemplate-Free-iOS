//
//  DemoOnboardingRepositoryTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
@testable import NativeAppTemplate

@Suite
struct DemoOnboardingRepositoryTest {
  @MainActor
  struct Tests {
    let repository = DemoOnboardingRepository()

    @Test
    func reload() {
      repository.reload()

      #expect(repository.onboardings.count == 13)
      #expect(!repository.onboardings.isEmpty)
    }

    @Test
    func onboardingsDictionary() {
      repository.reload()

      let dictionary = repository.onboardingsDictionary
      #expect(dictionary.count == 13)
      // Test specific values from the demo data
      #expect(dictionary[1] == false)  // Landscape
      #expect(dictionary[4] == true)   // Portrait
      #expect(dictionary[7] == true)   // Portrait
      #expect(dictionary[8] == true)   // Portrait
      #expect(dictionary[11] == true)  // Portrait
      #expect(dictionary[13] == false) // Landscape
    }

    @Test
    func onboardingProperties() {
      repository.reload()

      let firstOnboarding = repository.onboardings.first { $0.id == 1 }
      #expect(firstOnboarding != nil)
      #expect(firstOnboarding?.isPortraitImage == false)

      let portraitOnboarding = repository.onboardings.first { $0.id == 4 }
      #expect(portraitOnboarding != nil)
      #expect(portraitOnboarding?.isPortraitImage == true)
    }

    @Test
    func onboardingIds() {
      repository.reload()

      let ids = repository.onboardings.map { $0.id }.sorted()
      let expectedIds = Array(1...13)
      #expect(ids == expectedIds)
    }

    @Test
    func portraitImageCounts() {
      repository.reload()

      let portraitCount = repository.onboardings.filter { $0.isPortraitImage }.count
      let landscapeCount = repository.onboardings.filter { !$0.isPortraitImage }.count

      #expect(portraitCount == 4)  // IDs: 4, 7, 8, 11
      #expect(landscapeCount == 9) // All others
      #expect(portraitCount + landscapeCount == 13)
    }

    @Test
    func dictionaryConsistency() {
      repository.reload()

      // Verify that the dictionary computed property matches the onboardings array
      for onboarding in repository.onboardings {
        #expect(repository.onboardingsDictionary[onboarding.id] == onboarding.isPortraitImage)
      }
    }
  }
}
