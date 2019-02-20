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

    var webView: WKWebView = WKZombie.sharedInstance.webView

    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.enabled = true

        WKZombie.sharedInstance.snapshotHandler = { [weak self] snapshot in
//            self?.imageView.image = snapshot.image
        }

        

        checkGuestIn()

    }

    func checkGuestIn() {

        let url = URL(string: "http://www.parkingpermitsofamerica.com/PermitRegistration.aspx")!

//        let browser = WKZombie.sharedInstance

        open(url)
            >>> get(by: .id("cphMainCell_txtRegCode_I"))
            >>* setAttribute("value", value: "LCRVP")
//            >>* get(by: .name("ctl00$cphMainCell$btnRegCode"))
            >>> inspect()
            >>> execute("document.getElementsByName('ctl00$cphMainCell$btnRegCode')[0].click()")
            >>* inspect()
            >>* getAll(by: .contains("id", "cphMainCell_ddlPermitType_DDD_L_LBI1T0"))
            === handleResult

//        func myOutput(result: JavaScriptResult?) {
//            // handle result
//        }
//
//        browser.inspect

//        >>> browser.snap
//        === myOutput

    }

    func handleResult(_ result: Result<[HTMLTableRow]>) {
        switch result {
        case .success:
            print("Success")
        case .error:
            print("Error")
        }
    }
}
