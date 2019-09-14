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

        allGuests = Guest.allGuests()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkGuestIn" {
            
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

        cell.nameLabel.text = (guest.firstName + " " + guest.lastName).capitalized

        return cell
    }

}

class GuestTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
}

