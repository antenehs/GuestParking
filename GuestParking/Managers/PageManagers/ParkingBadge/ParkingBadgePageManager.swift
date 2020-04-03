//
//  ParkingBadgePageManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 10/21/19.
//  Copyright © 2019 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit

class ParkingBadgePageManager: NSObject, PageManager {

    enum HostDetailInputField: String, FieldKeys {
        case firstName = "tenant_firstname"
        case lastName = "tenant_lastname"
        case appartmentName = "apartment_complex_location"
        case appartmentID = "apartment_complex_id"
        case appartmentNumber = "tenant_number"
    }

    enum GuestDetailInputField: String, FieldKeys {
        case vehicleMake = "car_maker"
        case vehicleModel = "car_model"
        case vehiclePlateNumber = "license_plate"
        case phoneNumber = "phone"
        case emailAddress = "email"
    }

    private struct Constants {
        static let websiteEntryUrl = "https://app.parkingbadge.com/guest"
        static let checkinButtonClass = "btn btn-primary button"
        static let expiryDateFieldId = "end_at2"
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

    var webView: WKWebView = WKWebView(frame: .zero)

    var websiteEntryUrl: String {
        return Constants.websiteEntryUrl
    }

    var guest: Guest?
    var host: Host?

    private var currentPage = ParkingBadgeRegistrationPage.unknown

    override init() {
        super.init()

        self.webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        self.webView.navigationDelegate = self
    }

    func fillDetails() {
        if let host = self.host {
            fillHostDetails(host, usingKeys: HostDetailInputField.self)
        }

        if let guest = self.guest {
            fillGuestDetails(guest, usingKeys: GuestDetailInputField.self)
            webView.clickFirstButton(forClass: Constants.checkinButtonClass)
        }
    }

    func saveForm(completion: @escaping (Bool) -> Void) {

        saveForm(using: GuestDetailInputField.self,
                 hostKeys: HostDetailInputField.self) { (host, guest) in
            if var guest = guest, guest.vehiclePlateNumber != "" {
                guest.firstName = guest.vehicleMake
                guest.lastName = guest.vehicleModel
                guest.host = host

                guest.save()
                self.guest = guest

                if let host = host {
                    HostManager.shared.saveHost(host)
                }
                self.host = host
            }

            completion(true)
        }
    }

    private func getCurrentPage(completion: @escaping (ParkingBadgeRegistrationPage) -> Void) {

        webView.getPageSource { (htmlString) in
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

        webView.evaluateJavaScript("document.getElementById('\(Constants.expiryDateFieldId)').innerHTML") { value, _ in
            if let expiryDateString = value as? String {
                self.guest?.activePassMessage = "Expires On: \(expiryDateString)"
                self.guest?.activePassExpiryDate = ParkingBadgePageManager.expiryTimeStringToDate(expiryDateString)
                self.guest?.save()
                if let guest = self.guest {
                    self.completedCheckingIn(guest)
                }
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
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMMM dd yyyy, hh:mm a"
        return dateFormatter
    }()
}

extension ParkingBadgePageManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getCurrentPage { page in
            if page != self.currentPage {
                self.currentPage = page

                print("Current Page: \(page)")

                switch page {
                case .userDetail: self.fillDetails()
                case .completion: self.parseActivePassMessage()
                default:
                    print("Unknown page!!!!")
                }
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
    }
}
