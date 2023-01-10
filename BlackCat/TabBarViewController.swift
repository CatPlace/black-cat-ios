//
//  TabBarViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit
import ReactorKit
import BlackCatSDK
final class TabBarViewController: UITabBarController {
    
    // MARK: - Properties
    let homeVC = TabBarFactory.create(viewController: HomeViewController(),
                                                title: "홈",
                                                image: .ic_board,
                                                selectedImage: .ic_board_fill)
    let bookmarkVC = TabBarFactory.create(viewController: BookmarkViewController(),
                                          title: "좋아요",
                                          image: .ic_board,
                                          selectedImage: .ic_board_fill)

    let myPageVC = TabBarFactory.create(viewController: MyPageViewController(viewModel: .init()),
                                   title: "마이페이지",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    
    let temp = TabBarFactory.create(viewController: JHBusinessProfileViewController(viewModel: .init()),
                                   title: "작가프로필(지훈)",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        tabBar.tintColor = .darkGray
        tabBar.layer.cornerRadius = tabBar.frame.height * 0.41
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        modalPresentationStyle = .fullScreen
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        viewControllers = [homeVC, bookmarkVC, myPageVC, temp]
        delegate = self
    }
}


struct TabBarFactory {
    static func create(viewController: UIViewController,
                       title: String,
                       image: Asset,
                       selectedImage: Asset) -> UINavigationController {
        viewController.tabBarItem = UITabBarItem(title: title,
                                                 image: UIImage(image) ?? UIImage(),
                                                 selectedImage: UIImage(selectedImage) ?? UIImage())
        
        return UINavigationController(rootViewController: viewController)
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navigationController = viewController as? UINavigationController, let nextVC = navigationController.viewControllers.first {
            if nextVC is BookmarkViewController && CatSDKUser.userType() == .guest {
                // TODO: Alert
                print("게스트여서 안된다 Alert!", print(CatSDKUser.user()))
                return false
            }
        }
        return true
    }
}
