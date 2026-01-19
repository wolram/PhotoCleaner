# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Snap Sieve is a native macOS application (macOS 14.0+) that uses AI and computer vision to find and remove duplicate, similar, and low-quality photos. Built with SwiftUI, SwiftData, and Apple's Vision/CoreML frameworks.

**Note:** The repository directory is named "PhotoCleaner" but the application is branded as "Snap Sieve". The source code is in the `PhotoCleaner/` directory, tests in `PhotoCleanerTests/`, but the Xcode project, scheme, and bundle identifier all use "SnapSieve".

## Development Commands

### Project Setup

```bash
# Generate Xcode project (uses xcodegen)
./generate_project.sh

# Open project
open SnapSieve.xcodeproj
```

The project uses `xcodegen` to generate the Xcode project from `project.yml`. The generator script (`generate_project.sh`) will automatically install xcodegen via Homebrew if not present.

### Building

```bash
# Build from Xcode
Cmd+B

# Build from command line
xcodebuild -scheme SnapSieve -configuration Debug build

# Build for Release
xcodebuild -scheme SnapSieve -configuration Release build
```

### Testing

```bash
# Run all tests in Xcode
Cmd+U

# Run tests from command line
xcodebuild test -scheme SnapSieve

# Run specific test class
xcodebuild test -scheme SnapSieve -only-testing:SnapSieveTests/PerceptualHashTests

# Run specific test method
xcodebuild test -scheme SnapSieve -only-testing:SnapSieveTests/PerceptualHashTests/testHashSimilarity
```

**Test Coverage Areas:**
- `PerceptualHashTests.swift` - Perceptual hash computation and similarity
- `SimilarityTests.swift` - Photo similarity detection algorithms
- `ClusteringTests.swift` - DBSCAN clustering for grouping similar photos
- `QualityScoreTests.swift` - Quality assessment scoring logic
- `BestPhotoSelectorTests.swift` - Best photo selection algorithms

### Cleaning

```bash
# Clean build artifacts
xcodebuild clean -scheme SnapSieve

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/SnapSieve-*
```

## Architecture

### High-Level Structure

Snap Sieve follows a **layered, service-oriented architecture** with strict separation of concerns:

```
UI Layer (Features) → ViewModels → Services (Actors) → Repositories → SwiftData Models
```

### Core Architectural Patterns

**1. Actor-Based Concurrency**
- All services are Swift `actor` types for thread-safe concurrent operations
- Services are singletons: `await ServiceName.shared.method()`
- ViewModels are `@MainActor` to ensure UI updates on main thread

**2. Feature-Based Organization**
Each feature has its own directory under `Features/` containing:
- View (SwiftUI)
- ViewModel (MainActor, ObservableObject)
- Feature-specific models (if needed)

Features: Sieve, Categories, Duplicates, PhotoLibrary, Quality, Scanning, Similar

**3. Repository Pattern**
- `PhotoRepository` - CRUD operations for photos
- `GroupRepository` - CRUD operations for groups
- Both injected with SwiftData's `ModelContext`
- Repositories bridge between domain models and SwiftData entities

### Service Layer (7 Core Actor Services)

Located in `Core/Services/`:

1. **PhotoLibraryService** - Bridge to macOS Photos library via PhotoKit
   - Authorization, fetching assets, loading images, deletion
   - Handles thumbnail caching

2. **ImageAnalysisService** - Computer vision analysis via Vision framework
   - Feature prints (VNFeaturePrintObservation) for duplicate detection
   - Aesthetics, blur, and exposure analysis
   - Uses CoreImage filters

3. **QualityAssessmentService** - Multi-dimensional quality scoring
   - Composite score: `(aesthetics × 0.5) + (blur × 0.3) + (exposure × 0.2)`
   - Quality grades: A-F scale plus U for utility photos
   - Calls ImageAnalysisService for individual analyses

4. **DuplicateDetectionService** - Find exact/near-exact duplicates
   - Uses feature print distance (threshold: 0.5)
   - Groups overlapping duplicates

5. **SimilarityGroupingService** - Find visually similar photos
   - Perceptual hash + Hamming distance (threshold: 8)
   - DBSCAN clustering algorithm
   - Optional: embedding-based semantic similarity

6. **BatchProcessingService** - Concurrent photo processing
   - Configurable concurrency (default: 8 concurrent tasks)
   - Orchestrates ImageAnalysisService for batches
   - Returns ProcessingResult with all analysis data

7. **CLIPEmbeddingService** - Semantic embeddings (optional)
   - Advanced similarity via ML embeddings

### Data Flow: Scanning Workflow

The most complex flow in the app:

```
User clicks "Start Scan"
    ↓
ScanViewModel.startScan() [@MainActor]
    ↓
PHASE 1: LOADING
  PhotoLibraryService.fetchAllAssetIdentifiers() → [String]
    ↓
PHASE 2: ANALYZING
  BatchProcessingService.processPhotosIncrementally(batchSize=50)
    For each batch:
      - Generate feature print (duplicates)
      - Compute perceptual hash (similarity)
      - Analyze quality (aesthetics, blur, exposure)
    ↓
PHASE 3: INCREMENTAL GROUPING (real-time)
  ScanViewModel.processResultIncrementally()
    - DuplicateDetectionService.findDuplicates()
    - SimilarityGroupingService.groupSimilarPhotos()
    ↓
PHASE 4: FINALIZATION
  QualityAssessmentService.findLowQualityPhotos()
    ↓
PHASE 5: PERSISTENCE
  PhotoRepository.updateAnalysisResults() [batch]
  GroupRepository.createDuplicateGroups()
  GroupRepository.createSimilarGroups()
  modelContext.save()
```

**Key Point:** Detection happens **incrementally during analysis** (not in a separate pass), providing real-time feedback to users.

### SwiftData Models

Located in `Data/SwiftData/`:

**PhotoAssetEntity** - Core photo entity
- Unique identifier: `localIdentifier` (PhotoKit identifier)
- Analysis results: `featurePrintData`, `perceptualHash`, `aestheticScore`, `blurScore`, `exposureScore`
- ML results: `embeddingData`, category classifications
- Relationships: many-to-many with `PhotoGroupEntity`
- Computed properties: `compositeQualityScore`, `embedding`

**PhotoGroupEntity** - Groups of related photos
- Types: "duplicate", "similar", "burst"
- Relationships: many-to-many with `PhotoAssetEntity`
- Selection tracking: `selectedPhotoId` (user's choice of best photo)
- Computed properties: `spaceRecoverable`, `bestPhoto`, `photosToDelete`

**ScanSessionEntity** - Scan history and statistics
- Metadata: start/completion dates, status
- Statistics: photos scanned, duplicates/similar/low-quality found
- Space calculations: `spaceRecoverable`

### State Management

**AppState** (MainActor, ObservableObject)
- Global app state singleton
- Properties:
  - `isScanning: Bool`
  - `scanProgress: Double` (0.0-1.0)
  - `scanPhase: ScanPhase` (idle, loading, analyzing, grouping, complete)
  - Statistics: `photosScanned`, `duplicatesFound`, `similarGroupsFound`, etc.
- User preferences via `@AppStorage`:
  - `duplicateThreshold` (default: 0.5)
  - `similarityThreshold` (default: 8)
  - `qualityThreshold` (default: 0.3)

### Navigation Structure

Uses enum-based routing with `NavigationDestination`:

```swift
enum NavigationDestination {
    case library          // PhotoLibraryView
    case scan             // ScanView + ScanViewModel
    case duplicates       // DuplicatesView
    case similar          // SimilarPhotosView
    case quality          // QualityReviewView
    case sieve            // SieveView (gamified selection)
    case categories       // CategoriesView (ML categorization)
}
```

Organized in sidebar sections: Library, Cleanup, Organize

## Important Algorithms & Thresholds

### Duplicate Detection
- **Method:** VNFeaturePrintObservation distance comparison
- **Threshold:** Distance < 0.5 = exact duplicate
- **Implementation:** `DuplicateDetectionService`

### Similar Photo Detection
- **Method:** Perceptual hash + Hamming distance
- **Threshold:** Hamming distance ≤ 8 = similar
- **Implementation:** `PerceptualHash` algorithm + `SimilarityGroupingService`
- **Clustering:** DBSCAN with configurable epsilon

### Quality Assessment
- **Composite Score:** `(aesthetics × 0.5) + (blur × 0.3) + (exposure × 0.2)`
- **Utility Detection:** Screenshots, panoramas automatically marked as utility
- **Grading:**
  - A: 0.8-1.0 (excellent)
  - B: 0.6-0.8 (good)
  - C: 0.4-0.6 (average)
  - D: 0.2-0.4 (below average)
  - F: < 0.2 (poor)
  - U: utility photos (excluded from quality scoring)

### Best Photo Selection
- **Algorithm:** Multi-criteria ranking in `BestPhotoSelector`
- **Criteria:** Quality score, resolution, recency, user favorites
- **Implementation:** Weighted scoring with configurable weights

## Configuration

### AppConfig.swift
Central configuration file in `App/` containing:
- Batch sizes for processing
- Concurrency limits
- Threshold defaults
- Feature flags (if any)

### Info.plist Requirements
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Snap Sieve needs access to analyze and identify duplicates. All processing is local.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Snap Sieve needs permission to manage and delete photos.</string>
```

### Entitlements
Required entitlements in `SnapSieve.entitlements`:
- `com.apple.security.app-sandbox` (true)
- `com.apple.security.files.user-selected.read-write` (true)
- `com.apple.security.assets.pictures.read-write` (true)
- `com.apple.security.personal-information.photos-library` (true)

## Memory Management

### Key Considerations
- **Large Libraries:** Can have 50K+ photos
- **Batch Processing:** Default 50 photos per batch to manage memory
- **Thumbnail Caching:** PhotoLibraryService caches thumbnails
- **Actor Isolation:** Prevents race conditions in memory-intensive operations

### MemoryManager Utility
Located in `Core/Utilities/MemoryManager.swift`:
- Monitors memory pressure
- Clears caches when needed
- Respects system memory warnings

## Concurrency Model

### Structured Concurrency
- Uses Swift's native async/await throughout
- No completion handlers or callbacks (except for PhotoKit APIs)
- All service calls: `await service.method()`

### Task Groups
- `BatchProcessingService` uses task groups for parallel processing
- Configurable concurrency limit (default: 8)

### MainActor Isolation
- ViewModels: `@MainActor` ensures UI safety
- Use `@MainActor.run { }` when updating UI from background tasks

## Debugging

### Launch Arguments
Debug mode automatically includes:
- `-com.apple.CoreData.ConcurrencyDebug 1` (catches SwiftData threading issues)

### Common Debug Areas
1. **PhotoKit Authorization:** Check `PHPhotoLibrary.authorizationStatus()`
2. **SwiftData Context:** Ensure all SwiftData operations use correct ModelContext
3. **Actor Reentrancy:** Watch for deadlocks in actor methods
4. **Memory Pressure:** Monitor in Instruments for large libraries

### Logging
Add structured logging to Services for debugging:
```swift
print("[ServiceName] Operation: details")
```

## Building for App Store

### 1. Update Version
In Xcode Project Settings or Info.plist:
- `CFBundleShortVersionString`: Version (e.g., "1.0")
- `CFBundleVersion`: Build number (e.g., "1")

### 2. Configure Signing
- Select Apple Developer Team in Signing & Capabilities
- Verify entitlements are correct
- Verify bundle identifier is unique

### 3. Archive
```bash
# In Xcode
Product > Archive

# Or via command line
xcodebuild -scheme SnapSieve -configuration Release archive \
  -archivePath ./build/SnapSieve.xcarchive
```

### 4. Upload to App Store
1. Window > Organizer
2. Select archive
3. Validate App
4. Distribute App > Upload to App Store

## Performance Benchmarks

Tested on MacBook Pro M1, 16GB RAM:

| Library Size | Photos  | Scan Time | Typical Duplicates |
|--------------|---------|-----------|-------------------|
| Small        | 500     | ~30s      | 15-25             |
| Medium       | 5,000   | ~5min     | 150-300           |
| Large        | 50,000  | ~45min    | 1,500-3,000       |

### Optimization Points
- Batch size: 50 photos (balance between memory and feedback speed)
- Concurrency: 8 tasks (balance between CPU usage and responsiveness)
- Incremental detection: Real-time grouping as photos are analyzed

## Common Pitfalls

1. **SwiftData Context Threading:** Always use the correct ModelContext on the correct thread. Pass context to repositories.

2. **Actor Isolation:** Don't forget `await` when calling actor methods. Compiler will catch this.

3. **PhotoKit Async Bridging:** PhotoKit uses callbacks, not async/await. Wrap in `withCheckedContinuation` when needed.

4. **Feature Print Size:** VNFeaturePrintObservation data is large (~1-2KB per photo). Store as `Data` in SwiftData.

5. **Perceptual Hash Serialization:** Store as `UInt64` in SwiftData, convert to binary string for Hamming distance calculation.

6. **Quality Score vs Grade:** `compositeQualityScore` is numeric (0.0-1.0), `grade` is categorical (A-F, U). Don't confuse them.

## Project Structure Reference

```
PhotoCleaner/ (Source code directory, project name is SnapSieve)
├── App/                                # App entry point & global state
│   ├── SnapSieveApp.swift
│   ├── AppState.swift
│   └── AppConfig.swift
├── Core/
│   ├── Services/                       # 7 actor-based services
│   ├── Models/                         # Domain models (PhotoAsset, PhotoGroup, etc.)
│   ├── Algorithms/                     # PerceptualHash, Clustering, BestPhotoSelector
│   ├── ML/                             # ML model management (CLIP embeddings)
│   └── Utilities/                      # ImageProcessor, MemoryManager
├── Data/
│   ├── SwiftData/                      # 3 SwiftData entities
│   └── Repositories/                   # PhotoRepository, GroupRepository
├── Features/                           # 7 feature modules (each with View + ViewModel)
│   ├── Sieve/
│   ├── Categories/
│   ├── Duplicates/
│   ├── PhotoLibrary/
│   ├── Quality/
│   ├── Scanning/
│   └── Similar/
└── UI/
    ├── Navigation/                     # NavigationDestination, MainSidebar, ContentArea
    ├── Components/                     # Reusable UI (AsyncThumbnailImage, etc.)
    └── Styles/                         # Theme & styling
```
