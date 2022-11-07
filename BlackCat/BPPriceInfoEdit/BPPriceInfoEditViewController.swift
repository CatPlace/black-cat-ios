//
//  BPPriceInfoEditViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import UIKit
import SnapKit
import ReactorKit
import RxDataSources
import BlackCatSDK

final class BPPriceInfoEditViewController: UIViewController, View {
    typealias Reactor = BPPriceInfoEditReactor
    
    enum Reusable {
        static let textCell = ReusableCell<BPPriceInfoEditTextCell>()
        static let imageCell = ReusableCell<BPPriceInfoEditImageCell>()
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        dispatch(reactor: reactor)
        render(reactor: reactor)
    }
    
    private func dispatch(reactor: Reactor) {
        closeBarButtonItem.rx.tap
            .map { Reactor.Action.didTapCloseItem }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmBarButtonItem.rx.tap
            .compactMap { [weak self] _ in
                //                return self?.BPEditTextView.textStorage.description
                return ""
            }
            .map { Reactor.Action.didTapConfirmItem($0) }
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
        
        reactor.pulse(\.$isOpenPhotoLibrary)
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.openPhotoLibrary()
            }.disposed(by: disposeBag)
        
//        reactor.pulse(\.$sections)
        reactor.state.map { $0.sections }
            .asObservable()
            .bind(to: BPPriceInfoEditTableView.rx.items) { tv, row, item in
                let indexPath = IndexPath(row: row, section: 0)

                switch item.editModelRelay.value.type {
                case .text:
                    let cell = tv.dequeue(Reusable.textCell, for: indexPath)
                    cell.viewModel = item
                    cell.editTextView.delegate = self

                    return cell
                case .image:
                    let cell = tv.dequeue(Reusable.imageCell, for: indexPath)

                    return cell
                }
            }.disposed(by: disposeBag)
        
//        reactor.pulse(\.$sampleSections)
////        reactor.state.map { $0.sampleSections }
//            .map { $0.value }
//            .asObservable()
//            .bind(to: BPPriceInfoEditTableView.rx.items) { tv, row, item in
//                let indexPath = IndexPath(row: row, section: 0)
//
//                switch item.editModelRelay.value.type {
//                case .text:
//                    let cell = tv.dequeue(Reusable.textCell, for: indexPath)
//                    cell.viewModel = item
//                    cell.editTextView.delegate = self
//
//                    return cell
//                case .image:
//                    let cell = tv.dequeue(Reusable.imageCell, for: indexPath)
//
//                    return cell
//                }
//            }.disposed(by: disposeBag)
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
        configureBarButtonItem(sender: sender)
    }
    
    private func barButtonItemModifier(_ sender: UIBarButtonItem, title: String) {
        sender.title = title
        configureBarButtonItem(sender: sender)
    }
    
    private func configureBarButtonItem(sender: UIBarButtonItem) {
        sender.style = .plain
        sender.target = self
        sender.tintColor = .black
    }
    
    lazy var closeBarButtonItem: UIBarButtonItem = {
        barButtonItemModifier($0, systemName: "xmark")
        return $0
    }(UIBarButtonItem())
    
    lazy var confirmBarButtonItem: UIBarButtonItem = {
        barButtonItemModifier($0, title: "완료")
        return $0
    }(UIBarButtonItem())
    
    lazy var photoBarButtonItem: UIBarButtonItem = {
        barButtonItemModifier($0, systemName: "photo")
        return $0
    }(UIBarButtonItem())
    
    lazy var BPPriceInfoEditTableView: UITableView = {
        $0.backgroundColor = .blue
        $0.register(Reusable.textCell)
        $0.register(Reusable.imageCell)
        
        return $0
    }(UITableView())
}

extension BPPriceInfoEditViewController {
    func setUI() {
        self.navigationItem.leftBarButtonItems = [closeBarButtonItem]
        self.navigationItem.rightBarButtonItems = [confirmBarButtonItem]
        self.toolbarItems = [photoBarButtonItem]
        
        view.addSubview(BPPriceInfoEditTableView)
        BPPriceInfoEditTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BPPriceInfoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 🐻‍❄️ NOTE: PHPicker는 iOS 14+ 에서 사용가능합니다.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // 🐻‍❄️ NOTE: - editedImage를 사용합니다. 이미지 사이즈는 0 < height <= width 입니다.
        if let image = info[.editedImage] as? UIImage {
            let attachment = NSTextAttachment()
            
            reactor?.action.onNext(.appendImage(image))
            //            attachment.image = image.resize(newWidth: BPEditTextView.frame.width - 10)
            //            let attributedString = NSAttributedString(attachment: attachment)
            //            print("🌳 \(attachment)")
            //            self.BPEditTextView.textStorage.insert(attributedString,
            //                                                   at: self.BPEditTextView.selectedRange.location) // 현재 커서의 위치에 이미지 삽입
        } else {
            print("🚨 오잉? \(#function)에 문제가 있어요")
            // 🐻‍❄️ NOTE: - Error Handling
        }
    }
    
    private func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let vc = UIImagePickerController()
//            vc.modalPresentationStyle = .fullScreen
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


extension BPPriceInfoEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        BPPriceInfoEditTableView.beginUpdates()
        BPPriceInfoEditTableView.endUpdates()
    }
}
