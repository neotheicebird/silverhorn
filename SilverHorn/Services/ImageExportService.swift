// ImageExportService.swift
// Handles saving and sharing rendered card images.
//
// SPEC §21 — Two export options:
// 1. Share  → UIActivityViewController with all images
// 2. Save   → PHPhotoLibrary batch save to camera roll
//
// SPEC §20 — Progress indicator:
// The progress overlay is managed by MainScreen. This service performs
// the export operation and calls back on the main thread when done.
//
// PERMISSION HANDLING:
// NSPhotoLibraryAddUsageDescription is set in Info.plist.
// The system prompts the user automatically on first save.
// If denied, we call the completion with success=false; MainScreen
// can show a settings link (TODO in polish pass).

import UIKit
import Photos

enum ImageExportService {

    // MARK: - Share (spec §21)

    /// Presents a UIActivityViewController with all rendered images.
    /// Must be called on the main thread.
    static func share(images: [UIImage]) {
        guard !images.isEmpty else { return }

        let activityVC = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )

        // Find the frontmost view controller to present from.
        guard let presenter = topViewController() else { return }

        // iPad popover anchor — required to avoid crash on iPad (future-proof).
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.maxY - 100,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true)
    }

    // MARK: - Save to Library (spec §21)

    /// Saves all images to the user's camera roll using PHPhotoLibrary.
    /// Requests permission if not yet determined.
    /// - Parameter completion: Called on the main thread with success flag.
    static func saveToLibrary(images: [UIImage], completion: @escaping (Bool) -> Void) {
        // Check / request permission.
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            performSave(images: images, completion: completion)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    performSave(images: images, completion: completion)
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            }

        case .denied, .restricted:
            DispatchQueue.main.async { completion(false) }

        @unknown default:
            DispatchQueue.main.async { completion(false) }
        }
    }

    // MARK: - Private

    /// Saves images to the photo library in a single performChanges block.
    private static func performSave(images: [UIImage], completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            for image in images {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } completionHandler: { success, _ in
            DispatchQueue.main.async { completion(success) }
        }
    }

    /// Walks the view controller hierarchy to find the topmost presented controller.
    private static func topViewController() -> UIViewController? {
        guard
            let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: \.isKeyWindow)
        else { return nil }

        var top = window.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
