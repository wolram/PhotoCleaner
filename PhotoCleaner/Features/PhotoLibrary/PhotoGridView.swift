import SwiftUI

struct PhotoGridView: View {
    let photos: [PhotoAsset]
    @Binding var selection: Set<String>
    var onPhotoTap: ((PhotoAsset) -> Void)?
    var onPhotoDoubleTap: ((PhotoAsset) -> Void)?

    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    PhotoGridItem(
                        photo: photo,
                        isSelected: selection.contains(photo.id)
                    )
                    .onTapGesture {
                        toggleSelection(photo.id)
                        onPhotoTap?(photo)
                    }
                    .onTapGesture(count: 2) {
                        onPhotoDoubleTap?(photo)
                    }
                    .contextMenu {
                        contextMenu(for: photo)
                    }
                }
            }
            .padding(2)
        }
    }

    private func toggleSelection(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }

    @ViewBuilder
    private func contextMenu(for photo: PhotoAsset) -> some View {
        Button {
            if selection.contains(photo.id) {
                selection.remove(photo.id)
            } else {
                selection.insert(photo.id)
            }
        } label: {
            Label(
                selection.contains(photo.id) ? "Deselect" : "Select",
                systemImage: selection.contains(photo.id) ? "checkmark.circle" : "circle"
            )
        }

        Divider()

        Button {
            onPhotoDoubleTap?(photo)
        } label: {
            Label("View Details", systemImage: "info.circle")
        }

        if let date = photo.creationDate {
            Text("Taken: \(date.formatted(date: .abbreviated, time: .shortened))")
        }

        Text("Size: \(photo.formattedFileSize)")
        Text("Dimensions: \(photo.formattedDimensions)")
    }
}

// MARK: - Selectable Grid

struct SelectablePhotoGrid: View {
    let photos: [PhotoAsset]
    @Binding var selection: Set<String>
    let columns: Int

    var body: some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: columns)

        LazyVGrid(columns: gridColumns, spacing: 2) {
            ForEach(photos) { photo in
                PhotoGridItem(
                    photo: photo,
                    isSelected: selection.contains(photo.id),
                    showCheckbox: true
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if selection.contains(photo.id) {
                            selection.remove(photo.id)
                        } else {
                            selection.insert(photo.id)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoGridView(
        photos: [],
        selection: .constant(Set())
    )
}
