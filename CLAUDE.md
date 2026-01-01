# CLAUDE.md - PhotoCleaner AI Assistant Guide

> Last updated: 2026-01-01 | System Reboot Phase 1

---

## Architecture

### Overview
PhotoCleaner is a **macOS 14+** native photo management app built with **Swift 5.9**, **SwiftUI**, and **SwiftData**. It uses on-device ML for duplicate detection, similarity grouping, and quality assessment.

### Design Patterns
- **MVVM** - ViewModels coordinate between Views and Services
- **Actor-based Concurrency** - All services are Swift Actors for thread safety
- **Repository Pattern** - Data access abstraction over SwiftData
- **Singleton Services** - Shared instances for stateful services

### Layer Structure
```
┌─────────────────────────────────────────────────────┐
│  UI Layer (SwiftUI Views)                           │
│  └─ @MainActor ViewModels + @EnvironmentObject     │
├─────────────────────────────────────────────────────┤
│  Feature Layer (MVVM Modules)                       │
│  └─ Scanning, Duplicates, Similar, Quality,        │
│     Categories, PhotoLibrary, Settings             │
├─────────────────────────────────────────────────────┤
│  Service Layer (Actor-based, thread-safe)           │
│  └─ PhotoLibrary, ImageAnalysis, Duplicate,        │
│     Similarity, Quality, CLIP, BatchProcessing     │
├─────────────────────────────────────────────────────┤
│  Algorithm Layer (Pure computation)                 │
│  └─ PerceptualHash, Clustering, BestPhotoSelector  │
├─────────────────────────────────────────────────────┤
│  Repository Layer (Data Access)                     │
│  └─ PhotoRepository, GroupRepository               │
├─────────────────────────────────────────────────────┤
│  Data Layer (SwiftData Models)                      │
│  └─ PhotoAssetEntity, PhotoGroupEntity,            │
│     ScanSessionEntity                              │
└─────────────────────────────────────────────────────┘
```

### Key Directories
```
PhotoCleaner/
├── App/              # Entry point, AppState, AppConfig
├── Core/
│   ├── Services/     # 8 Actor-based services
│   ├── Algorithms/   # Hashing, clustering, scoring
│   ├── Models/       # Domain models
│   ├── ML/           # MLModelManager, EmbeddingCache
│   └── Utilities/    # ImageProcessor, MemoryManager
├── Data/
│   ├── SwiftData/    # Persistent entities
│   └── Repositories/ # Data access layer
├── Features/         # 7 feature modules (MVVM)
├── UI/
│   ├── Components/   # Reusable UI components
│   ├── Navigation/   # App navigation structure
│   └── Styles/       # Design system
└── Resources/        # Assets, Info.plist
```

---

## Commands

### Build & Run
```bash
# Generate Xcode project (preferred for development)
./generate_project.sh
open PhotoCleaner.xcodeproj

# Swift Package Manager
swift build                    # Build project
swift run                      # Run app
```

### Test
```bash
swift test                     # Run all tests
swift test --filter BestPhoto  # Run specific test file
```

### Development
```bash
# Package info
swift package describe
swift package show-dependencies

# Clean build
swift package clean
rm -rf .build
```

### Project Generation
```bash
# Requires: brew install xcodegen
./generate_project.sh          # Creates PhotoCleaner.xcodeproj
```

---

## Conventions

### Technology Stack
| Layer | Technology |
|-------|------------|
| Platform | macOS 14.0+ (Sonoma) |
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Persistence | SwiftData |
| Concurrency | Swift Actors, async/await, TaskGroup |
| ML/Vision | Vision Framework, CoreML |
| Image Processing | CoreImage, Accelerate |

### Apple Frameworks Used
- **Vision** - Feature extraction, aesthetics, blur detection
- **Photos** - Photo library access (PHPhotoLibrary)
- **CoreImage** - Image filtering & processing
- **Accelerate** - DCT computation (vectorized)
- **Combine** - Reactive patterns
- **AppKit** - macOS native features
- **os.log** - Performance logging

### No External Dependencies
This project uses **only Apple frameworks** - no third-party packages.

### Coding Standards
- **Actors** for all services (thread safety)
- **@MainActor** for all ViewModels
- **@Observable** for state management
- **async/await** for all async operations
- **Structured concurrency** with TaskGroups

### File Naming
- Services: `*Service.swift`
- ViewModels: `*ViewModel.swift`
- Views: `*View.swift`
- Entities: `*Entity.swift`
- Tests: `*Tests.swift`

### Configuration
All thresholds and settings centralized in `AppConfig.swift`:
- `duplicateDistance`: 0.5 (VNFeaturePrint threshold)
- `similarityThreshold`: 8 (Hamming distance)
- `qualityThreshold`: 0.3 (Minimum quality score)
- `maxConcurrentTasks`: 8
- `batchSize`: 100

### Test Coverage Focus
- Algorithms (hashing, clustering, scoring)
- Quality assessment logic
- Unit tests in `PhotoCleanerTests/`

### Privacy & Security
- All processing on-device
- App sandboxing enabled
- Explicit photo library permissions
- No analytics or telemetry
- No external API calls

---

## Current Status

### Implemented (Production-Ready)
- Photo library scanning with progress
- VNFeaturePrint duplicate detection
- Perceptual hash similarity grouping (DCT, Average, Difference)
- Quality assessment (blur, exposure, aesthetics)
- DBSCAN & Hierarchical clustering
- Multi-criteria best photo selection
- Memory pressure management
- SwiftData persistence
- Full navigation UI

### Placeholder/Incomplete
- **CLIPEmbeddingService** - Uses mock embeddings (needs real MobileCLIP model)
- **MLModelManager** - Skeleton ready for model integration
- **Burst detection** - Infrastructure exists, grouping not implemented
- **Batch deletion with undo** - Not implemented

### Test Status
- 5 test files, 22+ test cases
- Core algorithms well-tested
- UI/Integration tests minimal
