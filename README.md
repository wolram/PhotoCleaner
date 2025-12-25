# PhotoCleaner

A state-of-the-art macOS photo cleaning application built with Swift, SwiftUI, and Apple's Vision framework. Uses foundation models for intelligent duplicate detection, quality assessment, and AI-powered organization.

## Features

- **Duplicate Detection** - Uses Apple Vision's VNFeaturePrint for accurate duplicate identification
- **Similar Photo Grouping** - Perceptual hashing + DBSCAN clustering to find visually similar photos
- **Quality Assessment** - Analyzes aesthetics, blur, and exposure using Vision framework
- **AI Categorization** - MobileCLIP integration for zero-shot photo categorization
- **Smart Selection** - Multi-criteria algorithm to automatically select the best photo in each group
- **Privacy-First** - All processing happens on-device, no cloud uploads

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation

### Option 1: Open in Xcode (Recommended)

1. Open Xcode
2. File → New → Project
3. Choose "App" under macOS
4. Configure:
   - Product Name: PhotoCleaner
   - Bundle Identifier: com.yourname.photocleaner
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
5. Delete the generated source files
6. Drag the `PhotoCleaner` folder contents into the project
7. Add required frameworks: Vision, Photos, CoreML

### Option 2: Generate Xcode Project

```bash
cd PhotoCleaner
./generate_project.sh
open PhotoCleaner.xcodeproj
```

## Project Structure

```
PhotoCleaner/
├── App/                    # App entry point and state
├── Core/
│   ├── Models/            # Domain models
│   ├── Services/          # Business logic services
│   ├── ML/                # Machine learning components
│   ├── Algorithms/        # Hashing, clustering, selection
│   └── Utilities/         # Helpers and utilities
├── Data/
│   ├── SwiftData/         # SwiftData model definitions
│   └── Repositories/      # Data access layer
├── Features/
│   ├── PhotoLibrary/      # Photo browsing
│   ├── Scanning/          # Library scanning
│   ├── Duplicates/        # Duplicate review
│   ├── Similar/           # Similar photos review
│   ├── Quality/           # Quality-based filtering
│   ├── Categories/        # AI categories browser
│   └── Settings/          # App preferences
├── UI/
│   ├── Components/        # Reusable UI components
│   ├── Navigation/        # Navigation structure
│   └── Styles/            # Theme and styling
└── Resources/             # Assets and configuration
```

## Key Technologies

### Apple Vision Framework
- `VNGenerateImageFeaturePrintRequest` - Feature extraction for duplicate detection
- `CalculateImageAestheticsScoresRequest` - Image quality scoring (macOS 14+)
- Blur detection via edge analysis

### Perceptual Hashing
- DCT-based perceptual hash (pHash)
- 64-bit hash for fast similarity comparison
- Hamming distance for threshold-based grouping

### Clustering Algorithms
- DBSCAN for density-based clustering
- Hierarchical clustering with configurable linkage
- Union-Find for efficient group merging

### MobileCLIP Integration
- 512-dimensional image embeddings
- Zero-shot categorization
- Cosine similarity for semantic search

## Usage

1. **Grant Photo Access** - The app will request access to your photo library on first launch
2. **Scan Library** - Click "Scan" to analyze your photos for duplicates and quality
3. **Review Results** - Browse duplicate groups, similar photos, and low-quality images
4. **Smart Selection** - Use "Auto-Select Best" to automatically choose the best photo in each group
5. **Clean Up** - Delete unwanted photos to free up space

## Configuration

Settings can be adjusted in the Settings panel:

| Setting | Default | Description |
|---------|---------|-------------|
| Duplicate Threshold | 0.5 | VNFeaturePrint distance threshold (lower = stricter) |
| Similarity Threshold | 8 | Hamming distance for similar photos (lower = more similar) |
| Quality Threshold | 0.3 | Minimum quality score to avoid flagging |
| Concurrent Tasks | 8 | Number of parallel processing tasks |

## Privacy

PhotoCleaner is designed with privacy in mind:

- **On-Device Processing** - All photo analysis happens locally
- **No Cloud Uploads** - Your photos never leave your device
- **Minimal Permissions** - Only requests photo library access
- **Sandboxed** - Runs in macOS app sandbox

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Apple Vision Framework
- Apple MobileCLIP
- SwiftUI & SwiftData
