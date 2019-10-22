//
//  CheckinViewController.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 2/13/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import UIKit
import WebKit

class CheckinViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var saveActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var buttonsViewBottomConstraint: NSLayoutConstraint!

    var pageManager: PageManager!

    var guest: Guest?

    override func viewDidLoad() {
        super.viewDidLoad()

//        if guest == nil {
//            guest = Guest()
//            guest?.vehicleModel = "330i"
//            guest?.vehicleMake = "BMW"
//            guest?.vehicleYear = "2019"
//            guest?.vehiclePlateNumber = "LLO2140"
//            guest?.emailAddress = "someemial@gmail.com"
//            guest?.phoneNumber = "2340239087"
//        }

        pageManager = ParkingBadgePageManager(webView: webView)
//        pageManager.delegate = self

        loadInitialPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupButtonsView()
    }

    func loadInitialPage() {
        pageManager.checkGuestIn(guest) { success in

        }
    }

    func setupButtonsView() {
        let show = pageManager.isDetailsPage

        let bottomConstraintConstant = show ? 0 : (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + buttonsContainerView.frame.height

        buttonsViewBottomConstraint.constant = bottomConstraintConstant

        UIView.animate(withDuration: show ? 0.3 : 0) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func fillButtonTapped(_ sender: Any) {

//        pageManager.fillGuestDetails(for: guest ?? Guest())
    }

    /*

    @IBAction func saveGuestButtonTapped(_ sender: Any) {
        saveActivityIndicator.startAnimating()
        saveButton.setTitle("", for: .normal)
        pageManager.saveForm { (success) in
            // TODO: Show error
            self.saveActivityIndicator.stopAnimating()
            self.saveButton.setTitle("SAVE GUEST", for: .normal)
        }
    }

    */
}

extension CheckinViewController: WKUIDelegate {

}

extension CheckinViewController: PageManagerDelegate {
    func currentPageChangedTo(_ currentPage: ParkingPOARegistrationPage) {

        /*

        setupButtonsView()

        if currentPage == .codeEntry {
            pageManager.enterRegistrationCode()
        } else if currentPage == .userDetail {
            pageManager.fillGuestDetails(for: guest ?? Guest())
        }

        */
    }
}
