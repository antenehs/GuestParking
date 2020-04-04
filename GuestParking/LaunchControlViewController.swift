//
//  LaunchControlViewController.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/3/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import UIKit

class LaunchControlViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if SettingsManager.parkingSite != nil {
            showHomeController()
        } else {
            showSiteSelectorController()
        }
    }

    func showSiteSelectorController() {
        UIApplication.shared.delegate?.window??.rootViewController = SiteSelectionViewController.intantiateFromStroyBoard()
    }
    

    func showHomeController() {
        let homeNavController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!

        UIApplication.shared.delegate?.window??.rootViewController = homeNavController
    }
}
