// https://github.com/xcodeswift/sake

import Foundation
import SakefileDescription

let project = "HyperSpace"

var platform = ""

let destinations = [
  "macOS":   "\"platform=OS X\"",
  "iOS":     "\"platform=iOS Simulator,name=iPhone 8\"",
  "watchOS": "\"platform=watchOS Simulator,name=Apple Watch - 38mm\"",
  "tvOS":    "\"platform=tvOS Simulator,name=Apple TV\""
]

let sake = Sake(tasks: [
    Task("xcodegen-clean", description: "Removed XCode Project Data") {
        // Here is where you define your build task
        try Utils.shell.runAndPrint(bash: "rm -rf HyperSpace.xcodreproj")
        try Utils.shell.runAndPrint(bash: "rm -rf DerivedData")
    },
    Task("xcodegen", description: "Generate XCode Project Data") {
        // Here is where you define your build task
        try Utils.shell.runAndPrint(bash: "xcodegen")
    },
    Task("carthage-clean", description: "Cleans Project Carthage Dependencies") {
        // Here is where you define your build task
        try Utils.shell.runAndPrint(bash: "rm -rf Cartfile.resolved")
        try Utils.shell.runAndPrint(bash: "rm -rf Carthage")
    },
    Task("carthage-build-platform-dependencies", description: "Builds project Carthage dependencies for platform") {
        // Here is where you define your build task
        try Utils.shell.runAndPrint(bash: "carthage bootstrap --platform \(platform)")
        try Utils.shell.runAndPrint(bash: carthageBuild)
    },
    Task("xcode-build-platform", description: "Build specific platform with XCode") {
        // Here is where you define your build task
        let action = "xcodebuild clean build -project \(project).xcodeproj -scheme \(project)-\(platform) -quiet"
        try Utils.shell.runAndPrint(bash: action)
    },
    Task("xcode-test-platform", description: "Test specific platform with XCode. XCPretty output.") {
        // Here is where you define your build task
        guard let destination = destinations[platform] else { fatalError() }
        let action = "set -o pipefail && xcodebuild test -project \(project).xcodeproj -scheme \(project)-\(platform) -destination \(destination) -enableCodeCoverage YES | xcpretty"
        try Utils.shell.runAndPrint(bash: action)
    },

  ],


    hooks: [
        .beforeAll({
        /* Before all the tasks */
        do {
            platform = try Utils.shell.run(bash: "echo $PLATFORM")
        } catch {

        }

      })
    ]
)
