//
//  MainViewModel.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit

enum FilterType {
    case original
    case bw
}

protocol MainViewModelProtocol: AnyObject {
    
    var currentPhoto: PhotoModel? { get }
    var currentPhotoDidChange: ((PhotoModel?) -> Void)? { get set }
    var transformationDidChange: ((CGAffineTransform) -> Void)? { get set }
    
    init(photoManager: PhotoManagerProtocol, photoModelFactory: @escaping (UIImage) -> PhotoModel)
    
    func pickPhoto()
    func savePhoto(completion: @escaping (Bool, String) -> Void)
    func applyFilter(to photo: UIImage, filterType: FilterType) -> UIImage
    func updateTranslation(by translation: CGPoint)
    func updateScale(by scale: CGFloat)
    func updateRotation(by rotation: CGFloat)
}

final class MainViewModel: MainViewModelProtocol {

    internal var transformationDidChange: ((CGAffineTransform) -> Void)?
    internal var currentPhotoDidChange: ((PhotoModel?) -> Void)?
    internal var currentPhoto: PhotoModel?
    
    private let photoManager: PhotoManagerProtocol
    private let photoModelFactory: (UIImage) -> PhotoModel
    
    private var translation: CGPoint = .zero
    private var scale: CGFloat = 1.0
    private var rotation: CGFloat = 0.0
    
    init(photoManager: PhotoManagerProtocol, photoModelFactory: @escaping (UIImage) -> PhotoModel) {
        self.photoManager = photoManager
        self.photoModelFactory = photoModelFactory
    }
    
    // MARK: Work in Photo
    func pickPhoto() {
        photoManager.pickPhoto { [weak self] result in
            switch result {
            case .success(let image):
                guard let self = self else { return }
                let photoModel = self.photoModelFactory(image.image)
                self.currentPhoto = photoModel
                self.currentPhotoDidChange?(photoModel)
            case .failure(let error):
                print("Error picking photo: \(error)")
            }
        }
    }
    
    func savePhoto(completion: @escaping (Bool, String) -> Void) {
        guard let image = currentPhoto?.image else {
            return
        }
        
        photoManager.savePhoto(image) { success, error in
            if success {
                completion(true, "Фото успешно сохранено!")
            } else {
                let errorMessage = error?.localizedDescription ?? "Ошибка при сохранении фото."
                completion(false, errorMessage)
            }
        }
    }
    
    // MARK: Work in Filter
    func applyFilter(to photo: UIImage, filterType: FilterType) -> UIImage {
        switch filterType {
        case .bw:
            return applyBlackAndWhiteFilter(to: photo)
        default:
            return photo
        }
    }
    
    private func applyBlackAndWhiteFilter(to photo: UIImage) -> UIImage {
        let ciImage = CIImage(image: photo)
        let filter = CIFilter(name: "CIPhotoEffectNoir")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let outputImage = filter?.outputImage,
           let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return photo
    }
    
    // MARK: Work in Gesture
    func updateTranslation(by translation: CGPoint) {
        self.translation.x += translation.x
        self.translation.y += translation.y
        notifyTransformationChanged()
    }
    
    func updateScale(by scale: CGFloat) {
        self.scale *= scale
        notifyTransformationChanged()
    }
    
    func updateRotation(by rotation: CGFloat) {
        self.rotation += rotation
        notifyTransformationChanged()
    }
    
    private func notifyTransformationChanged() {
        let transform = CGAffineTransform.identity
            .translatedBy(x: translation.x, y: translation.y)
            .scaledBy(x: scale, y: scale)
            .rotated(by: rotation)
        transformationDidChange?(transform)
    }
}
