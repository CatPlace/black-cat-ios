//
//  SceneDelegate.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/10/03.
//

import UIKit
import RxSwift
import BlackCatSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        CatSDKUser.linkURLs(with: URLContexts)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        CatSDKUser.registerAppKeys()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        
        window?.rootViewController = LoginViewController(viewModel: .init())
        
        
        isLogined()
            .subscribe { _ in
                self.window?.rootViewController?.present(TabBarViewController(), animated: false)
            } onError: { error in
                CatSDKUser.updateUser(user: .init(id: -1))
            }

        window?.makeKeyAndVisible()
    }
    
    func isLogined() -> Observable<Void> {
        CatSDKBookmark.bookmarkListInSpecificUser(postType: .tattoo)
            .map { _ in () }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

}

