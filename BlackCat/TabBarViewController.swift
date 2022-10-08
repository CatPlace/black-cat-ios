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
    let vc = TabBarFactory.create(viewController: ViewController(),
                                                title: "dd",
                                                image: .ic_board,
                                                selectedImage: .ic_board_fill)
    
    let vc2 = TabBarFactory.create(viewController: MagazineDetailViewController(reactor: MagazineDetailViewController.Reactor()),
                                                title: "디테일",
                                                image: .ic_board,
                                                selectedImage: .ic_board_fill)

//    var homeViewController: UINavigationController
//    var magazineViewController: UINavigationController
//    var chatViewController: UINavigationController
//    var boardViewController: UINavigationController
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        tabBar.backgroundColor = .brown
        tabBar.tintColor = .darkGray
        tabBar.layer.cornerRadius = tabBar.frame.height * 0.41
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        viewControllers = [vc, vc2]
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
