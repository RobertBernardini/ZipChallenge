//
//  SettingsViewController.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/*
 View controller thay shows the app verison number and allows
 changing between light and dark mode in the app.
 */
final class SettingsViewController: UIViewController {
    enum Constants {
        static let darkModeCellIdentifier = "SettingsDarkModeCell"
        static let versionCellIdentifier = "SettingsVersionCell"
    }
    
    typealias ViewModel = SettingsViewModel
    var viewModel: SettingsViewModel!
    
    @IBOutlet var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
    }
    
    func configureUserInterface() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.rowHeight = 60
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.darkModeCellIdentifier,
                for: indexPath) as? SettingsDarkModeTableViewCell else {
                    return UITableViewCell()
            }
            cell.delegate = self
            cell.isDarkMode = viewModel.outputs.isDarkMode
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.versionCellIdentifier,
                for: indexPath) as? SettingsVersionTableViewCell else {
                    return UITableViewCell()
            }
            cell.version = viewModel.outputs.version
            cell.selectionStyle = .none
            return cell
        default: return UITableViewCell()
        }
    }
}

extension SettingsViewController: SettingsDarkModeTableViewCellDelegate {
    func settingsDarkModeTableViewCell(_ cell: SettingsDarkModeTableViewCell, didUpdateDarkMode isDarkMode: Bool) {
        viewModel.inputs.setDarkMode.accept(isDarkMode)
    }
}

extension SettingsViewController: ViewModelable {}
