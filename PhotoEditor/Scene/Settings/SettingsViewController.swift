//
//  SettingsViewController.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit

final class SettingsViewController: UIViewController {
    private let settingsViewModel: SettingsViewModelProtocol
    private let dataSource: SettingsDataSource

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(settingsViewModel: SettingsViewModelProtocol, dataSource: SettingsDataSource) {
        self.settingsViewModel = settingsViewModel
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        title = "Settings"
    }

    private func setupTableView() {
          tableView.dataSource = dataSource
          tableView.delegate = self
          tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
          tableView.frame = view.bounds
          tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          view.addSubview(tableView)
      }
}
// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        settingsViewModel.didSelectCell(at: indexPath) { [weak self] title, message in
            self?.showAlert(title: title, message: message)
        }
    }
}
