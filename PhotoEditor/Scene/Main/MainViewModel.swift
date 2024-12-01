//
//  MainViewModel.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import Foundation

protocol MainViewModelProtocol: AnyObject {
    
    var currentPhoto: PhotoModel? { get }
    var currentPhotoDidChange: ((PhotoModel?) -> Void)? { get set }
    var transformationDidChange: ((CGAffineTransform) -> Void)? { get set }
    
    init(photoManager: PhotoManagerProtocol, filterManager: FilterManagerProtocol, photoModelFactory: @escaping (Data) -> PhotoModel)
    
    func pickPhoto()
    func savePhoto(completion: @escaping (Bool, String) -> Void)
    func applyFilter(to photoData: Data, filterType: FilterType) -> Data?
    func updateTranslation(by translation: (x: Double, y: Double))
    func updateScale(by scale: Double)
    func updateRotation(by rotation: Double)
}

final class MainViewModel: MainViewModelProtocol {
    
    internal var transformationDidChange: ((CGAffineTransform) -> Void)?
    internal var currentPhotoDidChange: ((PhotoModel?) -> Void)?
    internal var currentPhoto: PhotoModel?
    
    private let filterManager: FilterManagerProtocol
    private let photoManager: PhotoManagerProtocol
    private let photoModelFactory: (Data) -> PhotoModel
    
    private var translation: (x: Double, y: Double) = (0, 0)
    private var scale: Double = 1.0
    private var rotation: Double = 0.0
    
    init(photoManager: PhotoManagerProtocol, filterManager: FilterManagerProtocol, photoModelFactory: @escaping (Data) -> PhotoModel) {
        self.photoManager = photoManager
        self.photoModelFactory = photoModelFactory
        self.filterManager = filterManager
    }
    
    // MARK: Work in Photo
    func pickPhoto() {
        photoManager.pickPhoto { [weak self] result in
            switch result {
            case .success(let data):
                guard let self = self else { return }
                let photoModel = self.photoModelFactory(data)
                self.currentPhoto = photoModel
                self.currentPhotoDidChange?(photoModel)
            case .failure(let error):
                print("Error picking photo: \(error)")
            }
        }
    }
    
    func savePhoto(completion: @escaping (Bool, String) -> Void) {
        guard let data = currentPhoto?.data else { return }
        photoManager.savePhoto(data) { success, error in
            if success {
                completion(true, "Фото успешно сохранено!")
            } else {
                let errorMessage = error?.localizedDescription ?? "Ошибка при сохранении фото."
                completion(false, errorMessage)
            }
        }
    }
    
    // MARK: Work in Filter
    func applyFilter(to photoData: Data, filterType: FilterType) -> Data? {
        return filterManager.applyFilter(to: photoData, filterType: filterType)
    }
    
    // MARK: Work in Gesture
    func updateTranslation(by translation: (x: Double, y: Double)) {
        self.translation.x += translation.x
        self.translation.y += translation.y
        notifyTransformationChanged()
    }
    
    func updateScale(by scale: Double) {
        self.scale *= scale
        notifyTransformationChanged()
    }
    
    func updateRotation(by rotation: Double) {
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
