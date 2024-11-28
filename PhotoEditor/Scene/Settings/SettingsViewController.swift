//
//  SettingsViewController.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    let settingViewModel: SettingsViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    init(settingViewModel: SettingsViewModel) {
        self.settingViewModel = settingViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
