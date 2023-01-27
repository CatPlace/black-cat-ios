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
    let imagePicker = ImagePickerController()
    
    func convertAssetToImage(_ sender: [PHAsset]) -> [UIImage] {
        var imageDataList: [UIImage] = []
        for i in 0..<sender.count {
            
            let imageManager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(for: sender[i],
                                      targetSize: .zero,
                                      contentMode: .aspectFill,
                                      options: option) { result, _ in
                guard let result else { return }
                imageDataList.append(result)
            }
        }
        return imageDataList
    }
}
