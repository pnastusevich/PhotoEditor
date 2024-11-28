//
//  ViewController.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        viewControllers = [
            generateNavigationController(rootViewController: MainViewController(),
                                         title: "Main",
                                         image: UIImage(systemName: "scribble.variable")!),
            generateNavigationController(rootViewController: SettingsViewController(),
                                         title: "Settings",
                                         image: UIImage(systemName: "scribble.variable")!)
        ]
    }
    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}

