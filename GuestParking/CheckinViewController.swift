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

    lazy var pageManager = { Register2ParkPageManager(webView: webView) }()

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

//        pageManager.delegate = self

        loadInitialPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupButtonsView()
    }

    func loadInitialPage() {
        pageManager.startGuestCheckIn(guest)
    }

    func setupButtonsView() {
        let show = pageManager.isManualEntry || pageManager.isManualSaving

        let bottomConstraintConstant = show ? 0 : view.safeAreaInsets.bottom + buttonsContainerView.frame.height

        buttonsViewBottomConstraint.constant = bottomConstraintConstant

        self.view.layoutIfNeeded()
    }

    @IBAction func fillButtonTapped(_ sender: Any) {

        pageManager.fillDetails()
    }

    @IBAction func saveGuestButtonTapped(_ sender: Any) {
        saveActivityIndicator.startAnimating()
        saveButton.setTitle("", for: .normal)
        pageManager.saveForm { (success) in
            // TODO: Show error
            self.saveActivityIndicator.stopAnimating()
            self.saveButton.setTitle("SAVE GUEST", for: .normal)
        }
    }
}
