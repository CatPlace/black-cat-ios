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
//    let seyeongViewController: UIViewController = {
//        let viewController = MagazineDetailViewController(nibName: nil, bundle: nil)
//
//        viewController.tabBarItem = UITabBarItem(title: "se0",
//                                                 image: UIImage(),
//                                                 tag: 0)
//        return viewController
//    }()
    
    lazy var vc = tabBarFactory(viewController: ViewController(), title: "dd", image: UIImage(.ic_board)!, selectedImage: UIImage(.ic_board_fill)!)
    
    lazy var vc2 = tabBarFactory(viewController: ViewController(), title: "dd", image: UIImage(.ic_board)!, selectedImage: UIImage(.ic_board_fill)!)

    var homeViewController: UINavigationController?
//    var magazineViewController: UINavigationController
//    var chatViewController: UINavigationController
//    var boardViewController: UINavigationController
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
//        homeViewController = tabBarFactory(viewController: ViewController(),
//                                           title: "dd",
//                                           image: UIImage(.ic_board) ?? UIImage(),
//                                           selectedImage: UIImage(.ic_board_fill) ?? UIImage())
        
        tabBar.tintColor = .blue
        
        tabBar.layer.cornerRadius = tabBar.frame.height * 0.41
        tabBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner]
        
        viewControllers = [vc, vc2]
    }
    
    private func tabBarFactory(
        viewController : UIViewController,
        title: String,
        image: UIImage,
        selectedImage: UIImage
    ) -> UINavigationController {
        
        vc.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
        let ro = UINavigationController(rootViewController: vc)
        return ro
    }
}

