//
//  Extenshion + UIViewController.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 29.11.24.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, buttonTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
