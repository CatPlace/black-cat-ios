//
//  UIImage+.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit
import RxSwift
extension UIImage {
    convenience init?(_ asset: Asset) {
        self.init(named: asset.rawValue, in: Bundle.main, with: nil)
    }
    
    convenience init?(assetName: String) {
        self.init(named: assetName, in: Bundle.main, with: nil)
    }
    
    /// 이미지 리사이징하는 함수입니다.
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    func roundedTabBarImageWithBorder(imageSize: CGSize = CGSize(width: 26, height: 26), width: CGFloat, color: UIColor?, defaultImage: Bool) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: imageSize))
        
        imageView.image = self
        imageView.layer.cornerRadius = imageSize.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color?.cgColor
        if defaultImage {
            imageView.contentMode = .center
            let render = UIGraphicsImageRenderer(size: imageSize)
            let renderImage = render.image { _ in
                guard let context = UIGraphicsGetCurrentContext() else { return }
                imageView.layer.render(in: context)
            }
            return renderImage
        } else {
            imageView.contentMode = .scaleAspectFill
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 3)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            imageView.layer.render(in: context)
            var result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            result = result?.withRenderingMode(.alwaysOriginal)
            return result
        }
    }
    
    static func convertToUIImage(_ sender: Any?) -> Observable<UIImage?> {
        if let data = sender as? Data {
            return .just(UIImage(data: data))
        } else if let string = sender as? String, let url = URL(string: string) {
            return URLSession.shared.rx.response(request: URLRequest(url: url)).map { UIImage(data: $1) }
        } else if let image = sender as? UIImage {
            return .just(image)
        }
        else {
            return .just(nil)
        }
    }
}
