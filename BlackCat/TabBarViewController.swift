//
//  TabBarViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import BlackCatSDK

final class TabBarViewController: UITabBarController {
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    let homeVC = TabBarFactory.create(viewController: HomeViewController(),
                                      title: "홈",
                                      image: .ic_home,
                                      selectedImage: .ic_home_fill)
    let bookmarkVC = TabBarFactory.create(viewController: BookmarkViewController(),
                                          title: "찜 목록",
                                          image: .ic_like,
                                          selectedImage: .ic_like_fill)
    
    let myPageVC = TabBarFactory.create(viewController: MyPageViewController(viewModel: .init()),
                                        title: "마이페이지",
                                        image: .ic_mypage,
                                        selectedImage: .ic_mypage)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        viewControllers = [homeVC, bookmarkVC, myPageVC]
        delegate = self
        configure()
        bind()
        modalPresentationStyle = .fullScreen
    }
    
    func bind() {
        Observable.merge([.just(CatSDKUser.user().imageUrl), CatSDKUser.imageUrlStringObservable()])
            .flatMap(UIImage.convertToUIImage)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, image in
                owner.updateMyPageButtonImage(image)
            }.disposed(by: disposeBag)
        
        CatSDKUser.userIdObservable()
            .filter { $0 == -2 }
            .delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, id in
                let vc = OneButtonAlertViewController(viewModel: .init(content: "로그인 시간이 만료되었습니다.\n로그인 페이지로 이동합니다.", buttonText: "확인"))
                vc.delegate = self
                owner.present(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    func configure() {
        tabBar.tintColor = .init(hex: "#7210A0FF")
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.appleSDGoithcFont(size: 12, style: .medium),
        ]
        tabBarItemAppearance.normal.titleTextAttributes = attributes
        tabBarItemAppearance.selected.titleTextAttributes = attributes
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.clearBackground()
        tabBar.standardAppearance = tabBarAppearance
                
        tabBar.layer.cornerRadius = tabBar.frame.height * 0.41
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
    }
    
    override func viewDidLayoutSubviews() {
        let height: CGFloat = 100
        tabBar.frame.size.height = height
        tabBar.frame.origin.y = view.frame.size.height - height
    }
    
    func updateMyPageButtonImage(_ sender: UIImage? = nil) {
        let image: UIImage?
        let isDefaultImage = sender == nil
        if let sender {
            image = sender
        } else {
            image = UIImage(.ic_mypage)?.resize(newWidth: 13.5)
        }
        myPageVC.tabBarItem.image = image?.roundedTabBarImageWithBorder(width: 2, color: .init(hex: "#C4C4C4FF"), defaultImage: isDefaultImage)
        myPageVC.tabBarItem.selectedImage = image?.roundedTabBarImageWithBorder(width: 2, color: .init(hex: "#7210A0FF"), defaultImage: isDefaultImage)
    }
}


struct TabBarFactory {
    static func create(viewController: UIViewController,
                       title: String,
                       image: Asset,
                       selectedImage: Asset) -> NavigationController {
        viewController.tabBarItem = UITabBarItem(title: title,
                                                 image: UIImage(image)?.resize(newWidth: 24) ?? UIImage(),
                                                 selectedImage: UIImage(selectedImage)?.resize(newWidth: 24) ?? UIImage())
        
        return NavigationController(rootViewController: viewController)
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navigationController = viewController as? NavigationController, let nextVC = navigationController.viewControllers.first {
            if nextVC is BookmarkViewController && CatSDKUser.userType() == .guest {
                let vc = LoginAlertViewController()
                present(vc, animated: true)
                return false
            }
        }
        return true
    }
}

extension TabBarViewController: OneButtonAlertDelegate {
    func didTapButton() {
        dismiss(animated: true)
    }
}
