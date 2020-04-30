//
//  SceneDelegate.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 25.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let tabBarController = TabBarViewController()
        
        let mainViewController = MainViewController(viewModel: MainViewModel(), andDataService: RailwayDataService())
        let mainTabItem = UITabBarItem()
        mainTabItem.title = "Home"
        mainTabItem.image = UIImage(named: "main-tabbar-icon")
        mainViewController.tabBarItem = mainTabItem

        let stationsNavController = UINavigationController()
        stationsNavController.isNavigationBarHidden = true
        
        let stationsViewController = StationsViewController(viewModel: StationsViewModel(), andDataService: RailwayDataService(), andRouter: StationsRouter(viewControler: stationsNavController))
        let stationsTabItem = UITabBarItem()
        stationsTabItem.title = "Stations"
        stationsTabItem.image = UIImage(named: "stations-tabbar-icon")
        stationsViewController.tabBarItem = stationsTabItem
        stationsNavController.viewControllers = [stationsViewController]
        
        let trainsViewController = TrainsViewController(viewModel: TrainsViewModel(), andDataService: RailwayDataService());
        let trainsTabItem = UITabBarItem()
        trainsTabItem.title = "Trains"
        trainsTabItem.image = UIImage(named: "trains-tabbar-icon")
        trainsViewController.tabBarItem = trainsTabItem
            
        
        tabBarController.viewControllers = [mainViewController, stationsNavController, trainsViewController]
        tabBarController.selectedViewController = mainViewController
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

