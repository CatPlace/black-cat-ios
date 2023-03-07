//
//  TwoButtonAlertViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/15.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import VisualEffectView

enum TwoButtonAlertType {
    case alertError
    case userReportwarning
    case warningCancelWriting
    case warningLogoutWriting
    case warningSecession
    case warningSecession2
    case warningDelete([Int])
    
    func getLeftButtonString() -> String {
        switch self {
        default:
            return "취소"
        }
    }
    
    func alertMessage() -> String {
        switch self {
        case .alertError:
            return "일시적인 오류입니다.\n 잠시후 다시 시도해주세요"
        case .userReportwarning:
            return "해당 타투이스트를 신고하시겠습니까?"
        case .warningCancelWriting:
            return "정말로 나가시겠습니까?\n변경사항은 저장되지 않습니다."
        case .warningLogoutWriting:
            return "로그아웃하시겠습니까?"
        case .warningSecession:
            return "탈퇴 하시겠습니까?"
        case .warningSecession2:
            return "정말 탈퇴를 진행하시겠습니까?\n지금까지의 사용기록이 전부 초기화됩니다."
        case .warningDelete(let indexList):
            return indexList.count == 0
            ? "삭제하시겠습니까?"
            : "\(indexList.count) 개를 삭제하시겠습니까?"
        }
    }
    
    func getLeftButtonColor() -> UIColor? {
        switch self {
        default:
            return .init(hex: "#999999FF")
        }
    }
    
    func getRightButtonString() -> String {
        switch self {
        case .userReportwarning:
            return "신고"
        case .warningCancelWriting:
            return "나가기"
        case .warningLogoutWriting:
            return "로그아웃"
        case .warningSecession:
            return "탈퇴"
        case .warningDelete:
            return "삭제"
        default:
            return "확인"
        }
    }
    func getRightButtonColor() -> UIColor? {
        switch self {
        default:
            return .init(hex: "#7210A0FF")
        }
    }
}

protocol TwoButtonAlertViewDelegate: AnyObject {
    func didTapRightButton(type: TwoButtonAlertType)
    func didTapLeftButton(type: TwoButtonAlertType)
}

struct TwoButtonAlertViewModel {
    let type: TwoButtonAlertType
    
    // MARK: Output
    let contentStringDriver: Driver<String>
    let leftButtonTextDriver: Driver<String>
    let leftTextColorDriver: Driver<UIColor?>
    let rightButtonTextDriver: Driver<String>
    let rightTextColorDriver: Driver<UIColor?>
    
    init(type: TwoButtonAlertType) {
        contentStringDriver = .just(type.alertMessage())
        leftButtonTextDriver = .just(type.getLeftButtonString())
        leftTextColorDriver = .just(type.getLeftButtonColor())
        rightButtonTextDriver = .just(type.getRightButtonString())
        rightTextColorDriver = .just(type.getRightButtonColor())
        self.type = type
    }
}

class TwoButtonAlertViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    weak var delegate: TwoButtonAlertViewDelegate?
    
    // MARK: - Binding
    func bind(to viewModel: TwoButtonAlertViewModel) {
        viewModel.contentStringDriver
            .drive(contentLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.leftButtonTextDriver
            .drive(leftLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.leftTextColorDriver
            .drive(leftLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        viewModel.rightButtonTextDriver
            .drive(rightLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.rightTextColorDriver
            .drive(rightLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        leftLabel.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .bind { owner, _ in
                owner.contentLabel.text = "처리중..."
                owner.delegate?.didTapLeftButton(type: viewModel.type)
            }.disposed(by: disposeBag)
        
        rightLabel.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .bind { owner, _ in
                owner.contentLabel.text = "처리중..."
                owner.delegate?.didTapRightButton(type: viewModel.type)
            }.disposed(by: disposeBag)
    }
    
    func configure() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
    }
    
    // MARK: - Initializer
    init(viewModel: TwoButtonAlertViewModel) {
        super.init(nibName: nil, bundle: nil)
        bind(to: viewModel)
        setUI()
        configure()
        [contentLabel, leftLabel, rightLabel].forEach(labelBuilder)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    let blurEffectView: VisualEffectView = {
        let v = VisualEffectView()
        v.colorTintAlpha = 1
        v.backgroundColor = .black.withAlphaComponent(0.6)
        v.blurRadius = 5
        return v
    }()
    let contentView = UIView()
    let contentLabel = UILabel()
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    let HLine: UIView = {
        $0.backgroundColor = .init(hex: "#C4C4C4FF")
        return $0
    }(UIView())
    let VLine: UIView = {
        $0.backgroundColor = .init(hex: "#C4C4C4FF")
        return $0
    }(UIView())
    func labelBuilder(_ sender: UILabel) {
        sender.font = .appleSDGoithcFont()
        sender.textAlignment = .center
    }
}

extension TwoButtonAlertViewController {
    func setUI() {
        view.addSubview(blurEffectView)
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
            
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(300 / 375.0)
            $0.height.equalToSuperview().multipliedBy(171 / 812.0)
        }
        
        [contentLabel, leftLabel, rightLabel, HLine, VLine].forEach { contentView.addSubview($0) }
        
        contentLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(121/171.0)
        }
        
        leftLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
            $0.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(50/171.0)
        }
        rightLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(2)
            $0.centerY.equalTo(leftLabel)
            $0.height.equalToSuperview().multipliedBy(50/171.0)
        }
        
        HLine.snp.makeConstraints {
            $0.bottom.equalTo(rightLabel.snp.top)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(1)
        }
        
        VLine.snp.makeConstraints {
            $0.height.equalTo(rightLabel).multipliedBy(0.4)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
            $0.centerY.equalTo(rightLabel)
        }
    }
}

