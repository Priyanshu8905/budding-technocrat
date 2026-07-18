# Hyperpure iOS App (SwiftUI + MVVM)

A native iOS B2B food supply mobile application inspired by **Hyperpure by Zomato**.

Built with:
- **Language**: Swift 6.0
- **Framework**: SwiftUI (iOS 17+)
- **Architecture**: MVVM (Model-View-ViewModel with `@Observable`)
- **IDE**: Xcode 15+ / Xcode 26+

## Project Structure
```
Hyperpure/
├── Hyperpure.xcodeproj/       # Xcode Project File
└── Hyperpure/
    ├── App/                  # App Entry Point & Theme
    ├── Models/               # Identifiable & Codable Models
    ├── ViewModels/           # Modern @Observable ViewModels
    ├── Views/                # SwiftUI Views with #Preview
    └── Data/                 # Mock Datasets
```

## How to Run
1. Open `Hyperpure/Hyperpure.xcodeproj` in Xcode.
2. Select any iOS Simulator target (e.g. `iPhone 17`).
3. Press `Cmd + R` to build and run.
