//
//  SettingsModel.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import Foundation

enum SettingsCellType {
    case about
}

struct SettingsCellModel {
    let title: String
    let cellType: SettingsCellType
}


