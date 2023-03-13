//
//  ImageCropableViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/03/14.
//

import UIKit
import Mantis
import Photos
import RxRelay

enum CropShapeType {
    case rect, circle
}

class ImageCropableViewController: UIViewController {
    var selectedImage = PublishRelay<UIImage?>()
    var cropShapeType: CropShapeType
    var config = Mantis.Config()
    
    init(cropShapeType: CropShapeType) {
        self.cropShapeType = cropShapeType
        super.init(nibName: nil, bundle: nil)
        setConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConfig() {
        config.cropToolbarConfig.ratioCandidatesShowType = .presentRatioList
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
        config.showRotationDial = false
        config.cropShapeType = cropShapeType == .circle ? .circle(maskOnly: false) : .rect
    }
    
    func activeActionSheet(with name: String) {
        let actionSheet = UIAlertController(title: "\(name) 이미지 관리", message: nil, preferredStyle: .actionSheet)
        let updateImageAction = UIAlertAction(title: "\(name) 이미지 변경", style: .default) { [weak self] action in
            guard let self else { return }
            self.openImageLibrary()
        }
        let deleteImageAction = UIAlertAction(title: "\(name) 이미지 삭제", style: .destructive) { [weak self] action in
            guard let self else { return }
            
            self.selectedImage.accept(nil)
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        [updateImageAction, deleteImageAction, actionCancel].forEach { actionSheet.addAction($0) }
        
        self.present(actionSheet, animated: true)
    }
    
    func openImageLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            present(imagePicker, animated: true)
        default:
            PHPhotoLibrary.requestAuthorization() { [weak self] afterStatus in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch afterStatus {
                    case .authorized:
                        self.present(imagePicker, animated: true)
                    case .denied:
                        self.moveToSetting()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func moveToSetting() {
        let alertController = UIAlertController(title: "권한 거부됨", message: "앨범 접근이 거부 되었습니다.\n 사진을 변경하시려면 설정으로 이동하여 앨범 접근 권한을 허용해주세요.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "설정으로 이동하기", style: .default) { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: false, completion: nil)
    }
}

extension ImageCropableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        
        picker.dismiss(animated: true) { [weak self] in
            guard let selectedImage, let self else { return }

            let cropViewController = Mantis.cropViewController(image: selectedImage, config: self.config)
            
            cropViewController.delegate = self
            self.present(cropViewController, animated: true)
        }
    }
}

extension ImageCropableViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation) {
        self.selectedImage.accept(cropped)
        dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        dismiss(animated: true)
    }
}
