//
//  FilterManager.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 1.12.24.
//

import CoreImage
import UIKit

protocol FilterManagerProtocol {
    func applyFilter(to imageData: Data, filterType: FilterType) -> Data?
}

final class FilterManager: FilterManagerProtocol {
    private let context = CIContext()

    func applyFilter(to imageData: Data, filterType: FilterType) -> Data? {
        guard let ciImage = CIImage(data: imageData) else { return nil }
        
        let filter: CIFilter?
        switch filterType {
        case .bw:
            filter = CIFilter(name: "CIPhotoEffectNoir")
        case .original:
            return imageData
        }

        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter?.outputImage else { return nil }

        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let filteredUIImage = UIImage(cgImage: cgImage)
            return filteredUIImage.pngData()
        }

        return nil
    }
}
