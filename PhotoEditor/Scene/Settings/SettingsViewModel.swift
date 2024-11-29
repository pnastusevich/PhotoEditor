//
//  SettigsViewModel.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import Foundation

protocol SettingsViewModelProtocol {
    var cells: [SettingsCellModel] { get }
    func didSelectCell(at indexPath: IndexPath, completion: (String, String) -> Void)
}

final class SettingsViewModel: SettingsViewModelProtocol {
    var cells: [SettingsCellModel] {
        return [SettingsCellModel(title: "Об приложении",
                                  cellType: .about
                                 )
        ]
    }

    func didSelectCell(at indexPath: IndexPath, completion: (String, String) -> Void) {
        let selectedCell = cells[indexPath.row]

        switch selectedCell.cellType {
        case .about:
            completion("Об приложении", "Тестовое задание выполнил: Настусевич Павел")
        }
    }
}
