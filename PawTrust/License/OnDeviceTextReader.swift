import UIKit
import Vision

enum OnDeviceTextReader {
    /// Reads text on device and returns lines only. The caller must drop them after whitelist extraction.
    static func recognize(_ image: UIImage) async -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        return await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["zh-Hans", "en-US"]
            request.usesLanguageCorrection = false
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                return []
            }
            return (request.results as? [VNRecognizedTextObservation])?.compactMap { observation in
                observation.topCandidates(1).first?.string
            } ?? []
        }.value
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    var onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImage: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImage: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImage = onImage
            self.dismiss = dismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            dismiss()
            if let image {
                onImage(image)
            }
        }
    }
}

struct PrivacyCover: View {
    var body: some View {
        ZStack {
            PawTheme.mapBackdrop.ignoresSafeArea()
            VStack(spacing: 8) {
                Image(systemName: "pawprint.fill")
                    .font(.largeTitle)
                    .foregroundStyle(PawTheme.cobalt)
                Text("证件画面已遮住")
                    .font(.headline)
            }
        }
        .accessibilityLabel("证件画面已遮住")
    }
}
