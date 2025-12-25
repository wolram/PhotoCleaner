import Foundation
import CoreML

actor MLModelManager {
    static let shared = MLModelManager()

    private var loadedModels: [String: MLModel] = [:]
    private var isLoading = false

    private init() {}

    // MARK: - Model Loading

    func loadAllModels() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Load CLIP model
        try await CLIPEmbeddingService.shared.loadModel()

        // Additional models can be loaded here
    }

    func loadModel(named name: String) async throws -> MLModel {
        if let existing = loadedModels[name] {
            return existing
        }

        // Try to load from bundle
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "mlmodelc") else {
            throw ModelError.modelNotFound(name)
        }

        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU

        let model = try await MLModel.load(contentsOf: modelURL, configuration: config)
        loadedModels[name] = model

        return model
    }

    func unloadModel(named name: String) {
        loadedModels.removeValue(forKey: name)
    }

    func unloadAllModels() {
        loadedModels.removeAll()
    }

    // MARK: - Model Info

    var loadedModelNames: [String] {
        Array(loadedModels.keys)
    }

    func isModelLoaded(_ name: String) -> Bool {
        loadedModels[name] != nil
    }

    // MARK: - Errors

    enum ModelError: Error, LocalizedError {
        case modelNotFound(String)
        case loadFailed(String)
        case predictionFailed(String)

        var errorDescription: String? {
            switch self {
            case .modelNotFound(let name):
                return "Model '\(name)' not found in bundle"
            case .loadFailed(let reason):
                return "Failed to load model: \(reason)"
            case .predictionFailed(let reason):
                return "Prediction failed: \(reason)"
            }
        }
    }
}

// MARK: - Model Configuration

extension MLModelManager {
    struct ModelConfig {
        let name: String
        let computeUnits: MLComputeUnits
        let preferredDevice: PreferredDevice

        enum PreferredDevice {
            case cpu
            case gpu
            case neuralEngine
            case auto
        }

        static let clipImage = ModelConfig(
            name: "MobileCLIP",
            computeUnits: .cpuAndNeuralEngine,
            preferredDevice: .neuralEngine
        )

        static let qualityAssessment = ModelConfig(
            name: "QualityAssessment",
            computeUnits: .cpuAndGPU,
            preferredDevice: .gpu
        )
    }

    func loadModel(config: ModelConfig) async throws -> MLModel {
        if let existing = loadedModels[config.name] {
            return existing
        }

        guard let modelURL = Bundle.main.url(forResource: config.name, withExtension: "mlmodelc") else {
            throw ModelError.modelNotFound(config.name)
        }

        let mlConfig = MLModelConfiguration()
        mlConfig.computeUnits = config.computeUnits

        let model = try await MLModel.load(contentsOf: modelURL, configuration: mlConfig)
        loadedModels[config.name] = model

        return model
    }
}
