//
//  BPProfileEditViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import SnapKit
import ReactorKit
import Photos

final class BPProfileEditViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = BPProfileEditReactor
    
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        BPEditTextView.rx.didBeginEditing
            .withUnretained(self)
            .bind { owner, _ in
                owner.BPEditTextView.font = UIFont.boldSystemFont(ofSize: 16)
            }.disposed(by: disposeBag)
        
        closeBarButtonItem.rx.tap
            .map { Reactor.Action.didTapCloseItem }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        photoBarButtonItem.rx.tap
            .map { Reactor.Action.didTapPhotoItem }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func render(reactor: Reactor) {
        reactor.state.map { $0.isDismiss }
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { owner, isDissmiss in
                owner.dismiss(animated: isDissmiss)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.isOpenPhotoLibrary }
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.openPhotoLibrary()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - initilaize
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    private func barButtonItemModifier(_ sender: UIBarButtonItem, systemName: String) {
        sender.image = UIImage(systemName: systemName)
        sender.style = .plain
        sender.target = self
        sender.tintColor = .black
    }
    
    lazy var closeBarButtonItem: UIBarButtonItem = {
        barButtonItemModifier($0, systemName: "xmark")
        return $0
    }(UIBarButtonItem())
    
    lazy var photoBarButtonItem: UIBarButtonItem = {
        barButtonItemModifier($0, systemName: "photo")
        return $0
    }(UIBarButtonItem())
    
    lazy var BPEditTextView: UITextView = {
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        return $0
    }(UITextView())
}

extension BPProfileEditViewController {
    func setUI() {
        self.navigationItem.leftBarButtonItems = [closeBarButtonItem]
        self.toolbarItems = [photoBarButtonItem]
        
        view.addSubview(BPEditTextView)
        BPEditTextView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BPProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 🐻‍❄️ NOTE: PHPicker는 iOS 14+ 에서 사용가능합니다.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // 🐻‍❄️ NOTE: - editedImage를 사용합니다. 이미지 사이즈는 0 < height <= width 입니다.
        if let image = info[.editedImage] as? UIImage {
            let attachment = NSTextAttachment()
            
            attachment.image = image.resize(newWidth: BPEditTextView.frame.width - 10)
            let attributedString = NSAttributedString(attachment: attachment)
            
            self.BPEditTextView.textStorage.insert(attributedString,
                                                   at: self.BPEditTextView.selectedRange.location) // 현재 커서의 위치에 이미지 삽입
        } else {
            print("🚨 오잉? \(#function)에 문제가 있어요")
            // 🐻‍❄️ NOTE: - Error Handling
        }
    }
    
    private func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let vc = UIImagePickerController()
            vc.modalPresentationStyle = .fullScreen
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            self.present(vc, animated: true)
        } else {
            print("🚨 권한 없어요 \(#function)")
            // 🐻‍❄️ NOTE: - Authorize Handling
        }
    }
}
