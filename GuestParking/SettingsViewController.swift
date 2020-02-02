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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        cell.selectionStyle = .none
        (cell.viewWithTag(1001) as? UISwitch)?.isOn = SettingsManager.remindExpiredPassed

        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {

}
