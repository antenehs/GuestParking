//
//  SettingsViewController.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 1/8/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "SETTINGS"

        tableView.reloadData()
    }

    @IBAction func reminderSwitchValueChanged(_ sender: UISwitch) {
        SettingsManager.remindExpiredPassed = sender.isOn
    }
}


extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
            (cell.viewWithTag(1001) as? UISwitch)?.isOn = SettingsManager.remindExpiredPassed
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
            cell.textLabel?.text = "Select Parking Manager"
        }

        cell.selectionStyle = .none
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectionVC = SiteSelectionViewController.intantiateFromStroyBoard()
            selectionVC.standalonMode = false
            
            navigationController?.pushViewController(selectionVC, animated: true)
        }
    }
}
