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

    var pageManager: PageManager!

    var guest = Guest(firstName: "Abera",
                      lastName: "Mola",
                      vehicleYear: "2017",
                      vehicleMake: "Kia",
                      vehicleModel: "Sonata",
                      vehicleColor: "white",
                      vehiclePlateState: "Texas (TX)",
                      vehiclePlateNumber: "TXC2304")

    override func viewDidLoad() {
        super.viewDidLoad()

        pageManager = PageManager(webView: webView)
        pageManager.delegate = self

        loadInitialPage()
    }

    func loadInitialPage() {

        let url = URL(string: "http://www.parkingpermitsofamerica.com/PermitRegistration.aspx")!

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    @IBAction func fillButtonTapped(_ sender: Any) {

        pageManager.fillGuestDetails(for: guest)
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

extension CheckinViewController: WKUIDelegate {

}

extension CheckinViewController: PageManagerDelegate {
    func currentPageChangedTo(_ currentPage: RegistrationPage) {
        if currentPage == .codeEntry {
            pageManager.enterRegistrationCode()
        } else if currentPage == .userDetail {
            pageManager.fillGuestDetails(for: guest)
        }
    }
}
