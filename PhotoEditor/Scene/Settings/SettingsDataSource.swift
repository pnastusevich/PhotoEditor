//
//  SettingsDataSource.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit

final class SettingsDataSource: NSObject, UITableViewDataSource {
    private let cellModels: [SettingsCellModel]

    init(cellModels: [SettingsCellModel]) {
        self.cellModels = cellModels
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") ?? UITableViewCell(style: .default, reuseIdentifier: "SettingsCell")
        cell.textLabel?.text = cellModels[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
