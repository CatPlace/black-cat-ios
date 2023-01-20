//
//  ImagePickerManager.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/20.
//

import UIKit
import BSImagePicker
import Photos

class ImagePickerManager {
    var photoImages: [UIImage]
    let imagePicker = ImagePickerController()
    
    
    init(photoImages: [UIImage] = []) {
        self.photoImages = photoImages
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
    }
    
    func convertAssetToImages(_ sender: [PHAsset]) {
        for i in 0..<sender.count {

            let imageManager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.deliveryMode = .highQualityFormat
            imageManager.requestImage(for: sender[i],
                                      targetSize: .zero,
                                      contentMode: .aspectFill,
                                      options: option) { [weak self] (result, info) in
                self?.photoImages.append(result!)
                print(result)
            }
        }
    }
}
