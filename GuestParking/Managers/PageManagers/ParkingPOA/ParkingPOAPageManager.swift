//
//  PageManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 8/13/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit
import HTMLReader

enum ParkingPOARegistrationPage: Int {
    case unknown = 0
    case codeEntry
    case permitSelection
    case userDetail
    case submition
    case confirmation

    var uniqueIdentifier: String {
        switch self {
        case .codeEntry: return "cphMainCell_txtRegCode_I"
        case .permitSelection: return "cphMainCell_ddlPermitType_I"
        case .userDetail: return "cphMainCell_txtNewPermitVehicleYear"
        case .submition: return "***IMPORTANT*** YOU HAVE NOT REGISTERED YOUR VEHICLE YET"
        case .confirmation: return "Print Permit"
        default:
            return "UnIdentifiedPage"
        }
    }
}

enum UserDetailInputField: String, FieldKeys {
    case firstName = "cphMainCell_txtNewPermitFirstName"
    case lastName = "cphMainCell_txtNewPermitLastName"
    case residentName = "cphMainCell_txtNewPermitResidentName"
    case residentAptNumber = "cphMainCell_txtNewPermitAptSteNumber"
    case vehicleYear = "cphMainCell_txtNewPermitVehicleYear"
    case vehicleMake = "cphMainCell_txtNewPermitMake"
    case vehicleModel = "cphMainCell_txtNewPermitModel"
    case vehicleColor = "cphMainCell_txtNewPermitColor"
    case vehiclePlateState = "cphMainCell_ddlNewPermitLicenseState_I"
    case vehiclePlateNumber = "cphMainCell_txtNewPermitLicenseNumber"
}

class ParkingPOAPageManager: NSObject, PageManager {
    var webView: WKWebView = WKWebView(frame: .zero)

    var guest: Guest?
    var host: Host?

    var websiteEntryUrl: String {
        return  "http://www.parkingpermitsofamerica.com/PermitRegistration.aspx"
    }

    var currentPage = ParkingPOARegistrationPage.unknown

    var isManualEntry: Bool {
        return true
    }

    var isManualSaving: Bool {
        return true
    }

    override init() {
        super.init()

        self.webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        self.webView.navigationDelegate = self
    }

    func getCurrentPage(completion: @escaping (ParkingPOARegistrationPage) -> Void) {

        webView.getPageSource { (htmlString) in
            guard let htmlString = htmlString else { completion(.unknown); return }

            var currentPage = ParkingPOARegistrationPage.unknown
            // THE ORDER IS VERY IMPORTANT
            for page in [ParkingPOARegistrationPage.codeEntry, ParkingPOARegistrationPage.userDetail, ParkingPOARegistrationPage.submition, ParkingPOARegistrationPage.permitSelection, ParkingPOARegistrationPage.confirmation] {
                if htmlString.contains(page.uniqueIdentifier) {
                    currentPage = page
                    break
                }
            }

            return completion(currentPage)
        }
    }

    func saveForm(completion: @escaping (Bool) -> Void) {
        guard currentPage == .userDetail else { completion(false); return }

        webView.getPageSource { (htmlString) in
            guard let htmlString = htmlString else { completion(false); return }

            let document = HTMLDocument(string: htmlString)

            var guest = Guest()
            guest.firstName = document.firstNode(matchingSelector: "#\(UserDetailInputField.firstName.fieldId)")?.attributes["value"] ?? ""
            guest.lastName = document.firstNode(matchingSelector: "#\(UserDetailInputField.lastName.fieldId)")?.attributes["value"] ?? ""
            guest.vehicleYear = document.firstNode(matchingSelector: "#\(UserDetailInputField.vehicleYear.fieldId)")?.attributes["value"] ?? ""
            guest.vehicleMake = document.firstNode(matchingSelector: "#\(UserDetailInputField.vehicleMake.fieldId)")?.attributes["value"] ?? ""
            guest.vehicleModel = document.firstNode(matchingSelector: "#\(UserDetailInputField.vehicleModel.fieldId)")?.attributes["value"] ?? ""
            guest.vehicleColor = document.firstNode(matchingSelector: "#\(UserDetailInputField.vehicleColor.fieldId)")?.attributes["value"] ?? ""
            guest.vehiclePlateState = document.firstNode(matchingSelector: "#\(UserDetailInputField.vehiclePlateState.fieldId)")?.attributes["value"] ?? ""
            guest.vehiclePlateNumber = document.firstNode(matchingSelector: "#\(UserDetailInputField.vehiclePlateNumber.fieldId)")?.attributes["value"] ?? ""

            if guest.vehiclePlateNumber != "" {
                guest.save()
            }

            completion(guest.vehiclePlateNumber != "")
        }
    }

    func enterRegistrationCode() {
        let registrationCode = HostManager.shared.latestHost()?.parkingCode ?? ""

        webView.setValue(registrationCode, toFieldWithId: "cphMainCell_txtRegCode_I")
        webView.clickFirstButton(forName: "ctl00$cphMainCell$btnRegCode")
    }

    func fillDetails() {
        guard let guest = self.guest else { return }

        webView.setValue(guest.firstName ?? "", toFieldWithId: UserDetailInputField.firstName.fieldId)
        webView.setValue(guest.lastName ?? "", toFieldWithId: UserDetailInputField.lastName.fieldId)
        webView.setValue(guest.vehicleYear ?? "", toFieldWithId: UserDetailInputField.vehicleYear.fieldId)
        webView.setValue(guest.vehicleMake ?? "", toFieldWithId: UserDetailInputField.vehicleMake.fieldId)
        webView.setValue(guest.vehicleModel ?? "", toFieldWithId: UserDetailInputField.vehicleModel.fieldId)
        webView.setValue(guest.vehicleColor ?? "", toFieldWithId: UserDetailInputField.vehicleColor.fieldId)
        webView.setValue(guest.vehiclePlateState ?? "", toFieldWithId: UserDetailInputField.vehiclePlateState.fieldId)
        webView.setValue(guest.vehiclePlateNumber, toFieldWithId: UserDetailInputField.vehiclePlateNumber.fieldId)

        webView.setValue(HostManager.shared.latestHost()?.fullName ?? "", toFieldWithId: UserDetailInputField.residentName.fieldId)
        webView.setValue(HostManager.shared.latestHost()?.appartmentNumber ?? "", toFieldWithId: UserDetailInputField.residentAptNumber.fieldId)

        webView.clickFirstButton(forName: "ctl00$cphMainCell$btnNewPermitSubmit")
    }
}

extension ParkingPOAPageManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getCurrentPage { page in
            if page != self.currentPage {
                self.currentPage = page

                print("Current Page: \(page)")
            }
        }
    }
}
