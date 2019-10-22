//
//  ParkingBadgePageManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 10/21/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit
import HTMLReader

class ParkingBadgePageManager: NSObject, PageManager {

    private enum UserDetailInputField: String {
        case appartmentName = "apartment_complex_location"
        case appartmentID = "apartment_complex_id"
        case residentFirstName = "tenant_firstname"
        case residentLastName = "tenant_lastname"
        case residentAptNumber = "tenant_number"
        case vehicleMake = "car_maker"
        case vehicleModel = "car_model"
        case vehicleLicensePlate = "license_plate"
        case guestPhoneNumber = "phone"
        case guestEmailAddress = "email"

        var fieldId: String { return rawValue }
    }

    private enum ParkingBadgeRegistrationPage {
        case unknown
        case userDetail
        case completion

        var uniqueIdentifier: String {
            switch self {
            case .userDetail: return "apartment_complex_location"
            case .completion: return "print-btn"
            default:
                return "UnIdentifiedPage"
            }
        }
    }

    weak var webView: WKWebView!
    var guest: Guest?

    private var currentPage = ParkingBadgeRegistrationPage.unknown

    var isDetailsPage: Bool {
        return false
    }

    required init(webView: WKWebView) {
        super.init()

        self.webView = webView
        self.webView.navigationDelegate = self
    }

    func checkGuestIn(_ guest: Guest?, completion: (Bool) -> Void) {
        self.guest = guest

        let url = URL(string: "https://app.parkingbadge.com/guest")!

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }

    func fillGuestDetails() {

        if let guest = self.guest {
            setValue(guest.vehicleMake, toFieldWithId: UserDetailInputField.vehicleMake.fieldId)
            setValue(guest.vehicleModel, toFieldWithId: UserDetailInputField.vehicleModel.fieldId)
            setValue(guest.vehiclePlateNumber, toFieldWithId: UserDetailInputField.vehicleLicensePlate.fieldId)
            setValue(guest.phoneNumber, toFieldWithId: UserDetailInputField.guestPhoneNumber.fieldId)
            setValue(guest.emailAddress, toFieldWithId: UserDetailInputField.guestEmailAddress.fieldId)
        }

        setValue(UserManager.shared.appartmentName, toFieldWithId: UserDetailInputField.appartmentName.fieldId)
        setValue(UserManager.shared.appartmentID, toFieldWithId: UserDetailInputField.appartmentID.fieldId)
        setValue(UserManager.shared.firstName, toFieldWithId: UserDetailInputField.residentFirstName.fieldId)
        setValue(UserManager.shared.lastName, toFieldWithId: UserDetailInputField.residentLastName.fieldId)
        setValue(UserManager.shared.aptNumber, toFieldWithId: UserDetailInputField.residentAptNumber.fieldId)

        if guest != nil {
            clickFirstButton(forClass: "btn btn-primary button")
        }
    }

    func saveForm(completion: @escaping (Bool) -> Void) {
        guard currentPage == .userDetail else { completion(false); return }

        var guest = Guest()

        let group = DispatchGroup()

        group.enter()
        self.webView.evaluateJavaScript("document.getElementById('\(UserDetailInputField.vehicleMake.fieldId)').value") { value, _ in
            guest.vehicleMake = value as? String ?? ""
            group.leave()
        }

        group.enter()
        self.webView.evaluateJavaScript("document.getElementById('\(UserDetailInputField.vehicleModel.fieldId)').value") { value, _ in
            guest.vehicleModel = value as? String ?? ""
            group.leave()
        }

        group.enter()
        self.webView.evaluateJavaScript("document.getElementById('\(UserDetailInputField.vehicleLicensePlate.fieldId)').value") { value, _ in
            guest.vehiclePlateNumber = value as? String ?? ""
            group.leave()
        }

        group.enter()
        self.webView.evaluateJavaScript("document.getElementById('\(UserDetailInputField.guestPhoneNumber.fieldId)').value") { value, _ in
            guest.phoneNumber = value as? String ?? ""
            group.leave()
        }

        group.enter()
        self.webView.evaluateJavaScript("document.getElementById('\(UserDetailInputField.guestEmailAddress.fieldId)').value") { value, _ in
            guest.emailAddress = value as? String ?? ""
            group.leave()
        }

        group.notify(queue: .main) {
            if guest.vehiclePlateNumber != "" {
                guest.firstName = guest.vehicleMake
                guest.lastName = guest.vehicleModel
                guest.save()

                self.guest = guest
            }

            completion(guest.vehiclePlateNumber != "")
        }
    }

    private func getCurrentPage(completion: @escaping (ParkingBadgeRegistrationPage) -> Void) {

        getPageSource { (htmlString) in
            guard let htmlString = htmlString else { completion(.unknown); return }

            var currentPage = ParkingBadgeRegistrationPage.unknown
            for page in [ParkingBadgeRegistrationPage.userDetail, ParkingBadgeRegistrationPage.completion] {
                if htmlString.contains(page.uniqueIdentifier) {
                    currentPage = page
                    break
                }
            }

            return completion(currentPage)
        }
    }

    private func parseActivePassMessage(completion: ((String?) -> Void)? = nil) {
        guard currentPage == .completion  else { completion?(nil); return }

        webView.evaluateJavaScript("document.getElementById('end_at2').innerHTML") { value, _ in
            if let expiryDateString = value as? String {
                self.guest?.activePassMessage = "Expires On: \(expiryDateString)"
                self.guest?.activePassExpiryDate = ParkingBadgePageManager.expiryTimeStringToDate(expiryDateString)
                self.guest?.save()
            }
            completion?(value as? String)
        }
    }

    private static func expiryTimeStringToDate(_ dateString: String) -> Date? {
        // eg. October 22nd 2019, 7:17 pm
        var components = dateString.components(separatedBy: .whitespaces)
        if components.count > 1 {
            var secondComponent = components[1]
            secondComponent = secondComponent.replacingOccurrences(of: "st", with: "")
            secondComponent = secondComponent.replacingOccurrences(of: "nd", with: "")
            secondComponent = secondComponent.replacingOccurrences(of: "rd", with: "")
            secondComponent = secondComponent.replacingOccurrences(of: "th", with: "")
            components[1] = secondComponent
        }

        let modifiedString = components.joined(separator: " ")

        return dateFormatter.date(from: modifiedString)
    }

    static let dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy, hh:mm a"
        return dateFormatter
    }()
}

extension ParkingBadgePageManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getCurrentPage { page in
            if page != self.currentPage {
                self.currentPage = page

                switch page {
                case .userDetail: self.fillGuestDetails()
                case .completion: self.parseActivePassMessage()
                default:
                    print("Unknown page!!!!")
                }

                print("Current Page: \(page)")
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if currentPage == .userDetail {
            saveForm { _ in
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }

//        self.webView.evaluateJavaScript("document.getElementById('\(UserDetailInputField.vehicleMake.fieldId)').value") { value, _ in
//            print("Car Make::: \(value)")
//            decisionHandler(.allow)
//        }
    }
}
