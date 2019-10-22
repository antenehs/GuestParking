//
//  ViewController.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 2/13/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var allGuests = [Guest]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadGuests()

        tableView.allowsSelectionDuringEditing = false
        tableView.allowsMultipleSelectionDuringEditing = false
    }

    func reloadGuests() {
        allGuests = Guest.allGuests()

        allGuests.sort { (g1, g2) -> Bool in
            g1.activePermitDisplayString ?? "zzzz" < g2.activePermitDisplayString ?? "zzzz"
        }

        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkGuestIn" {
            if let index = tableView.indexPathForSelectedRow {
                (segue.destination as? CheckinViewController)?.guest = allGuests[index.row]
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
            tableView.reloadData()
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

        nameLabel.text = (guest.firstName + " " + guest.lastName).capitalized
        detailLabel.text = guest.vehicleMake + " 𐄁 " + guest.vehicleModel + " 𐄁 " + guest.vehiclePlateNumber

        if let activePassMessage = guest.activePermitDisplayString {
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

