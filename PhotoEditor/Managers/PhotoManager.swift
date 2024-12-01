//
//  ImageManager.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit
import Photos

enum PhotoManagerError: Error {
    case photoLibraryUnavailable
    case viewControllerUnavailable
    case accessDenied
}

protocol PhotoManagerProtocol {
    func pickPhoto(completion: @escaping (Result<Data, Error>) -> Void)
    func savePhoto(_ photoData: Data, completion: @escaping (Bool, Error?) -> Void)
}

class PhotoManager: PhotoManagerProtocol {
    
    private let picker = UIImagePickerController()
    
    func pickPhoto(completion: @escaping (Result<Data, Error>) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            completion(.failure(PhotoManagerError.photoLibraryUnavailable))
            return
        }
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = PhotoPickerDelegate.shared
        
        PhotoPickerDelegate.shared.completionHandler = { result in
            switch result {
            case .success(let image):
                if let data = image.pngData() {
                    completion(.success(data))
                } else {
                    completion(.failure(PhotoManagerError.photoLibraryUnavailable))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            completion(.failure(PhotoManagerError.viewControllerUnavailable))
            return
        }
        rootViewController.present(picker, animated: true)
        
    }
    
    func savePhoto(_ photoData: Data, completion: @escaping (Bool, Error?) -> Void) {
        guard let image = UIImage(data: photoData) else {
            completion(false, PhotoManagerError.photoLibraryUnavailable)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false, PhotoManagerError.accessDenied)
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            completion(true, nil)
        }
    }
}

private class PhotoPickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = PhotoPickerDelegate()
    
    var completionHandler: ((Result<UIImage, Error>) -> Void)?

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                completionHandler?(.success(image))
            } else {
                completionHandler?(.failure(PhotoManagerError.photoLibraryUnavailable))
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler?(.failure(PhotoManagerError.photoLibraryUnavailable))
            picker.dismiss(animated: true)
        }
}
