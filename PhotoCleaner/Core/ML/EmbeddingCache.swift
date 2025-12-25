import Foundation

actor EmbeddingCache {
    static let shared = EmbeddingCache()

    private var cache: [String: CacheEntry] = [:]
    private var accessOrder: [String] = []
    private let maxSize: Int

    struct CacheEntry {
        let embedding: [Float]
        let timestamp: Date
    }

    init(maxSize: Int = 10000) {
        self.maxSize = maxSize
    }

    // MARK: - Cache Operations

    func get(_ id: String) -> [Float]? {
        guard let entry = cache[id] else { return nil }

        // Move to end of access order (LRU)
        accessOrder.removeAll { $0 == id }
        accessOrder.append(id)

        return entry.embedding
    }

    func set(_ id: String, embedding: [Float]) {
        // Evict oldest if at capacity
        while cache.count >= maxSize {
            evictOldest()
        }

        cache[id] = CacheEntry(embedding: embedding, timestamp: Date())
        accessOrder.append(id)
    }

    func contains(_ id: String) -> Bool {
        cache[id] != nil
    }

    func remove(_ id: String) {
        cache.removeValue(forKey: id)
        accessOrder.removeAll { $0 == id }
    }

    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }

    // MARK: - Batch Operations

    func getMany(_ ids: [String]) -> [String: [Float]] {
        var result: [String: [Float]] = [:]
        for id in ids {
            if let embedding = get(id) {
                result[id] = embedding
            }
        }
        return result
    }

    func setMany(_ embeddings: [String: [Float]]) {
        for (id, embedding) in embeddings {
            set(id, embedding: embedding)
        }
    }

    func getMissing(_ ids: [String]) -> [String] {
        ids.filter { cache[$0] == nil }
    }

    // MARK: - Eviction

    private func evictOldest() {
        guard let oldest = accessOrder.first else { return }
        cache.removeValue(forKey: oldest)
        accessOrder.removeFirst()
    }

    func evictOlderThan(_ date: Date) {
        let toRemove = cache.filter { $0.value.timestamp < date }.map { $0.key }
        for id in toRemove {
            cache.removeValue(forKey: id)
            accessOrder.removeAll { $0 == id }
        }
    }

    // MARK: - Statistics

    var count: Int {
        cache.count
    }

    var hitRate: Double {
        // This would need tracking of hits/misses
        0.0
    }

    var memoryUsage: Int {
        // Approximate memory usage
        // Each Float is 4 bytes, typical embedding is 512 floats = 2KB
        // Plus overhead for dictionary keys
        cache.count * (512 * 4 + 100)
    }

    var formattedMemoryUsage: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryUsage), countStyle: .memory)
    }
}

// MARK: - Disk Cache

actor DiskEmbeddingCache {
    private let cacheDirectory: URL
    private let fileManager = FileManager.default

    init() throws {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("EmbeddingCache", isDirectory: true)

        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Cache Operations

    func get(_ id: String) async -> [Float]? {
        let fileURL = cacheDirectory.appendingPathComponent(sanitize(id))

        guard let data = fileManager.contents(atPath: fileURL.path) else {
            return nil
        }

        return data.withUnsafeBytes { buffer in
            Array(buffer.bindMemory(to: Float.self))
        }
    }

    func set(_ id: String, embedding: [Float]) async throws {
        let fileURL = cacheDirectory.appendingPathComponent(sanitize(id))
        let data = embedding.withUnsafeBytes { Data($0) }
        try data.write(to: fileURL)
    }

    func remove(_ id: String) async throws {
        let fileURL = cacheDirectory.appendingPathComponent(sanitize(id))
        try? fileManager.removeItem(at: fileURL)
    }

    func clear() async throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for file in contents {
            try fileManager.removeItem(at: file)
        }
    }

    // MARK: - Helpers

    private func sanitize(_ id: String) -> String {
        // Replace characters that aren't safe for filenames
        id.replacingOccurrences(of: "/", with: "_")
           .replacingOccurrences(of: ":", with: "_")
    }

    var count: Int {
        (try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil).count) ?? 0
    }

    var diskUsage: Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        return contents.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + Int64(size)
        }
    }
}
