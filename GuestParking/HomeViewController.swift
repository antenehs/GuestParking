//
//  ViewController.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 2/13/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    class func intantiateFromStroyBoard() -> HomeViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! HomeViewController
    }

    @IBOutlet var emptyView: UIView!

    var allGuests = [Guest]()
    var parkingSite = SettingsManager.parkingSite ?? ParkingSite.register2Park

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = nil

        NotificationCenter.default.addObserver(forName: .parkingSiteChanged,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
                                                self?.parkingSite = SettingsManager.parkingSite ?? ParkingSite.register2Park
                                                self?.reloadGuests()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadGuests()

        tableView.allowsSelectionDuringEditing = false
        tableView.allowsMultipleSelectionDuringEditing = false
    }

    @IBAction func reloadGuests() {
        allGuests = Guest.allGuests().filter { $0.parkingSite == parkingSite }

        allGuests.sort { (g1, g2) -> Bool in
            g1.activePassMessage ?? "zzzz" < g2.activePassMessage ?? "zzzz"
        }

        tableView.backgroundView = allGuests.count == 0 ? emptyView : nil
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkGuestIn" {
            let destination = segue.destination as? CheckinViewController
            destination?.parkingSite = parkingSite
            if let index = tableView.indexPathForSelectedRow {
                destination?.guest = allGuests[index.row]
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allGuests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell", for: indexPath) as! GuestTableViewCell

        let guest = allGuests[indexPath.row]

        cell.setupFor(guest: guest)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let guest = (tableView.cellForRow(at: indexPath) as? GuestTableViewCell)?.guest {
            guest.delete()

            allGuests = Guest.allGuests()
            reloadGuests()
        }
    }
}

class GuestTableViewCell: UITableViewCell {
    var guest: Guest!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var activePassLabel: UILabel!

    @IBOutlet var activePassVerticalSpacingConstraint: NSLayoutConstraint!

    func setupFor(guest: Guest) {
        self.guest = guest

        nameLabel.text = ((guest.firstName ?? "") + " " + (guest.lastName ?? "")).capitalized
        detailLabel.text = "\(guest.vehicleMake ?? "") 𐄁 \(guest.vehicleModel ?? "") 𐄁 \(guest.vehiclePlateNumber)"

        if let activePassMessage = self.guest.activePermitDisplayString() {
            activePassLabel.isHidden = false
            activePassLabel.text = activePassMessage
            activePassVerticalSpacingConstraint.isActive = true
        } else {
            activePassLabel.isHidden = true
            activePassLabel.text = nil
            activePassVerticalSpacingConstraint.isActive = false
        }
    }
}

