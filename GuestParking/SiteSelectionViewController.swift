//
//  SiteSelectionViewController.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/3/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import UIKit

class SiteSelectionViewController: UIViewController {

    class func intantiateFromStroyBoard() -> SiteSelectionViewController {
        return UIStoryboard(name: "ParkingSite", bundle: nil).instantiateInitialViewController() as! SiteSelectionViewController
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!

    var standalonMode = true

    private let allSites = ParkingSite.allCases

    private var selectedRow: Int? {
        didSet {
            continueButton.isEnabled = selectedRow != nil
            continueButton.backgroundColor = selectedRow != nil ? UIColor.appTintColor : UIColor.secondaryBackgroundColor

            if !standalonMode {
                SettingsManager.parkingSite = selectedRow != nil ? allSites[selectedRow!] : nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let selected = SettingsManager.parkingSite {
            selectedRow = allSites.index(of: selected)
        }
        continueButton.isHidden = !standalonMode
        continueButton.backgroundColor = UIColor.secondaryBackgroundColor
        tableView.reloadData()
    }

    @IBAction
    func continueButtonTapped(_ sender: UIButton) {
        if standalonMode {
            SettingsManager.parkingSite = selectedRow != nil ? allSites[selectedRow!] : nil

            let noSitesGuests = Guest.allGuests().filter { $0.parkingSite == nil }
            for var guest in noSitesGuests {
                guest.parkingSite = SettingsManager.parkingSite
                guest.save()
            }

            showHomeController()
        }
    }

    private func showHomeController() {
        let homeNavController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!

        UIApplication.shared.delegate?.window??.rootViewController = homeNavController
    }
}

extension SiteSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell", for: indexPath) as! SiteTableViewCell

        cell.setUp(for: allSites[indexPath.row])
        if !standalonMode {
            cell.contentView.alpha = selectedRow == indexPath.row ? 1 : 0.5
        }
        cell.accessoryType = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row

        (0..<allSites.count).forEach {
            let cell = tableView.cellForRow(at: IndexPath(row: $0, section: 0))
            cell?.contentView.alpha = $0 == indexPath.row ? 1 : 0.5
        }

        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.contentView.alpha = 0.5
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedRow == indexPath.row ? 130.0 : 90
    }
}

class SiteTableViewCell: UITableViewCell {
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backgroundContainerView: UIView!

    var parkingSite: ParkingSite!

    func setUp(for parkingSite: ParkingSite) {
        self.parkingSite = parkingSite

        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = parkingSite.logoImage
    }
}
