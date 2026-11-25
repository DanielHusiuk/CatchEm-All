//
//  SceneDelegate.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 10.11.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let api: ApiManagerProtocol
        
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-uiTesting") {
            let mock = MockApiManager()
            
            if ProcessInfo.processInfo.arguments.contains("-failFirstPage") {
                mock.pageFailures = 1
            }
            api = mock
        } else {
            api = ApiManager()
        }
#else
        api = ApiManager()
#endif
        
        let viewModel = ListViewModel(api: api)
        let mainViewController = ListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.tintColor = .customRed
        self.window = window
        window.makeKeyAndVisible()
    }
    
}
