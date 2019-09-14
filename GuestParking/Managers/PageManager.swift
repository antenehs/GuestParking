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

enum RegistrationPage: Int {
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

enum UserDetailInputField: String {
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

    var fieldId: String { return rawValue }
}

protocol PageManagerDelegate: class {
    func currentPageChangedTo(_ currentPage: RegistrationPage)
}

class PageManager: NSObject {

    weak var webView: WKWebView!
    weak var delegate: PageManagerDelegate?

    var currentPage = RegistrationPage.unknown

    init(webView: WKWebView) {
        super.init()

        self.webView = webView
        self.webView.navigationDelegate = self
    }

    func getCurrentPage(completion: @escaping (RegistrationPage) -> Void) {

        getPageSource { (htmlString) in
            guard let htmlString = htmlString else { completion(.unknown); return }

            var currentPage = RegistrationPage.unknown
            // THE ORDER IS VERY IMPORTANT
            for page in [RegistrationPage.codeEntry, RegistrationPage.userDetail, RegistrationPage.submition, RegistrationPage.permitSelection, RegistrationPage.confirmation] {
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

        getPageSource { (htmlString) in
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
        let registrationCode = UserManager.shared.parkingCode

        setValue(registrationCode, toFieldWithId: "cphMainCell_txtRegCode_I")
        clickFirstButton(forName: "ctl00$cphMainCell$btnRegCode")
    }

    func fillGuestDetails(for guest: Guest) {

        setValue(guest.firstName, toFieldWithId: UserDetailInputField.firstName.fieldId)
        setValue(guest.lastName, toFieldWithId: UserDetailInputField.lastName.fieldId)
        setValue(guest.vehicleYear, toFieldWithId: UserDetailInputField.vehicleYear.fieldId)
        setValue(guest.vehicleMake, toFieldWithId: UserDetailInputField.vehicleMake.fieldId)
        setValue(guest.vehicleModel, toFieldWithId: UserDetailInputField.vehicleModel.fieldId)
        setValue(guest.vehicleColor, toFieldWithId: UserDetailInputField.vehicleColor.fieldId)
        setValue(guest.vehiclePlateState, toFieldWithId: UserDetailInputField.vehiclePlateState.fieldId)
        setValue(guest.vehiclePlateNumber, toFieldWithId: UserDetailInputField.vehiclePlateNumber.fieldId)

        setValue(UserManager.shared.fullName, toFieldWithId: UserDetailInputField.residentName.fieldId)
        setValue(UserManager.shared.aptNumber, toFieldWithId: UserDetailInputField.residentAptNumber.fieldId)

        clickFirstButton(forName: "ctl00$cphMainCell$btnNewPermitSubmit")
    }

    private func setValue(_ value: String, toFieldWithId id: String) {
        webView.evaluateJavaScript("document.getElementById('\(id)').value = '\(value)'") { _, _ in }
    }

    private func clickFirstButton(forName name: String) {
        webView.evaluateJavaScript("document.getElementsByName('\(name)')[0].click()") { _, _ in }
    }

    private func getPageSource(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.documentElement.innerHTML") { (html, error) in
            completion(html as? String)
        }
    }
}

extension PageManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getCurrentPage { page in
            if page != self.currentPage {
                self.delegate?.currentPageChangedTo(page)
                self.currentPage = page

                print("Current Page: \(page)")
            }
        }
    }
}
