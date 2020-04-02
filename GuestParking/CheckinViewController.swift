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

//    @IBOutlet var webView: WKWebView!
    @IBOutlet var saveActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var buttonsViewBottomConstraint: NSLayoutConstraint!

    var pageManager = Register2ParkPageManager()

    var guest: Guest?

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = pageManager.webView
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: buttonsContainerView.topAnchor)
        ])

        loadInitialPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupButtonsView()
    }

    func loadInitialPage() {
        #if DEBUG
        if false, guest == nil {
            guest = Guest(phoneNumber: "2340239087", emailAddress: "someemial@gmail.com", vehicleYear: "2019", vehicleMake: "BMW", vehicleModel: "M5", vehicleColor: "Red", vehiclePlateState: "TX", vehiclePlateNumber: "LLO2140", host: Host())
        }
        #endif
        pageManager.startGuestCheckIn(guest)
    }

    func setupButtonsView() {
        let show = pageManager.isManualEntry || pageManager.isManualSaving

        let bottomConstraintConstant = show ? 0 : (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0) + buttonsContainerView.frame.height

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
