//
//  TabBarViewController.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/08.
//

import UIKit
import ReactorKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Properties
    let vc = TabBarFactory.create(viewController: FilterExampleViewController(),
                                  title: "dd",
                                  image: .ic_board,
                                  selectedImage: .ic_board_fill)
    
    let vc2 = TabBarFactory.create(viewController: MagazineDetailViewController(reactor: MagazineDetailViewController.Reactor()),
                                   title: "디테일",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    let vc3 = TabBarFactory.create(viewController: MagazineViewController(),
                                   title: "매거진",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    let vc4 = TabBarFactory.create(viewController: BusinessProfileViewController(),
                                   title: "임시뷰",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    let vc5 = TabBarFactory.create(viewController: BPEditTempViewController(),
                                   title: "에딧",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    let vc6 = TabBarFactory.create(viewController: LoginViewController(viewModel: .init()),
                                   title: "로그인",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    let vc7 = TabBarFactory.create(viewController: MyPageViewController(viewModel: .init()),
                                   title: "마이페이지",
                                   image: .ic_board,
                                   selectedImage: .ic_board_fill)
    //    var homeViewController: UINavigationController
    //    var magazineViewController: UINavigationController
    //    var chatViewController: UINavigationController
    //    var boardViewController: UINavigationController
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        tabBar.tintColor = .darkGray
        tabBar.layer.cornerRadius = tabBar.frame.height * 0.41
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        viewControllers = [vc, vc2, vc3, vc4, vc5, vc6, vc7]
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
