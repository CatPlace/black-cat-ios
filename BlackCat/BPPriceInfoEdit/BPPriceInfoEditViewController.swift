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
import RxKeyboard
import RxCocoa

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
        RxKeyboard.instance.visibleHeight
            .skip(1)    // 초기 값 버리기
            .drive(with: self) { owner, keyboardVisibleHeight in
                
                owner.updateView(with: keyboardVisibleHeight)
            }.disposed(by: disposeBag)
        
        closeBarButtonItem.rx.tap
            .map { Reactor.Action.didTapCloseItem }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmBarButtonItem.rx.tap
            .compactMap { [weak self] _ in
                // TODO: - 서버로 보내기.
                
                return ""
            }
            .map { Reactor.Action.didTapConfirmItem($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        photoToolbarButton.rx.tap
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
        
        reactor.state.map { $0.sections }
            .map { $0.value }
            .bind(to: BPPriceInfoEditTableView.rx.items) { tv, row, item in
                let indexPath = IndexPath(row: row, section: 0) // NOTE: - 섹션 하나

                switch item.editModelRelay.value.type {
                case .text:
                    let cell = tv.dequeue(Reusable.textCell, for: indexPath)
                    cell.viewModel = item
                    cell.editTextView.delegate = self

                    return cell
                case .image:
                    let cell = tv.dequeue(Reusable.imageCell, for: indexPath)
                    cell.viewModel = item
                    
                    return cell
                }
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Function
    func updateView(with keyboardHeight: CGFloat) {
        toolBarView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight)
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
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
    private func configureButton(sender: Any) {
        if let sender = sender as? UIBarButtonItem {
            sender.style = .plain
            sender.target = self
            sender.tintColor = .black
        }
        else if let sender = sender as? UIButton {
            sender.tintColor = .black
        } else { print("🚨 \(#function) error ")}
    }
    
    lazy var closeBarButtonItem: UIBarButtonItem = {
        $0.image = UIImage(systemName: "xmark")
        configureButton(sender: $0)
        return $0
    }(UIBarButtonItem())
    
    lazy var confirmBarButtonItem: UIBarButtonItem = {
        $0.title = "완료"
        configureButton(sender: $0)
        return $0
    }(UIBarButtonItem())
    
    lazy var BPPriceInfoEditTableView: UITableView = {
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        $0.register(Reusable.textCell)
        $0.register(Reusable.imageCell)
        
        return $0
    }(UITableView())
    
    lazy var toolBarView: UIView = {
        $0.backgroundColor = .white
        return $0
    }(UIView())
    
    lazy var photoToolbarButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        let image = UIImage(systemName: "photo", withConfiguration: config)
        $0.setImage(image, for: .normal)
        
        configureButton(sender: $0)
        return $0
    }(UIButton())
}

extension BPPriceInfoEditViewController {
    func setUI() {
        self.navigationItem.leftBarButtonItems = [closeBarButtonItem]
        self.navigationItem.rightBarButtonItems = [confirmBarButtonItem]
        
        view.addSubview(BPPriceInfoEditTableView)
        BPPriceInfoEditTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(toolBarView)
        let toolbarHeight = 50
        toolBarView.snp.makeConstraints {
            $0.height.equalTo(toolbarHeight) // 🐻‍❄️ NOTE: - 시스템 툴바 height 25
            $0.leading.trailing.bottom.equalToSuperview()
        }
        toolBarView.addSubview(photoToolbarButton)
        photoToolbarButton.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview()
            $0.width.height.equalTo(toolbarHeight)
        }
    }
}

extension BPPriceInfoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 🐻‍❄️ NOTE: PHPicker는 iOS 14+ 에서 사용가능합니다.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // 🐻‍❄️ NOTE: - editedImage를 사용합니다. 이미지 사이즈는 0 < height <= width 입니다.
        if var image = info[.editedImage] as? UIImage {
            image = image.resize(newWidth: UIScreen.main.bounds.width)
            reactor?.action.onNext(.appendImage(image))
        } else {
            print("🚨 \(#function)에 문제가 있어요")
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


extension BPPriceInfoEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        BPPriceInfoEditTableView.beginUpdates()
        BPPriceInfoEditTableView.endUpdates()
    }
}
