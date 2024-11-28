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
            generateNavigationController(rootViewController: makeMainViewController(),
                                         title: "Main",
                                         image: UIImage(systemName: "scribble.variable")!),
            generateNavigationController(rootViewController: makeSettingsViewController(),
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
    
    private func makeMainViewController() -> UIViewController {
            let photoManager = PhotoManager()
        let photoModelFactory: (UIImage) -> PhotoModel = { image in
            PhotoModel(image: image)
        }
            let mainViewModel = MainViewModel(photoManager: photoManager, photoModelFactory: photoModelFactory)
            return MainViewController(mainViewModel: mainViewModel)
        }
        
    private func makeSettingsViewController() -> UIViewController {
        let settingsViewModel = SettingsViewModel()
        return SettingsViewController(settingViewModel: settingsViewModel)
        }
}

