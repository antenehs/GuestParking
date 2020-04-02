//
//  Register2ParkPageManager.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 3/31/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation
import WebKit

class Register2ParkPageManager: NSObject, PageManager {
    typealias HostDetailFields = HostDetailInputField
    typealias GuestDetailFields = GuestDetailInputField

    enum HostDetailInputField: String, FieldKey {
        case appartmentName = "propertyName"
        case appartmentNumber = "vehicleApt"
    }

    enum GuestDetailInputField: String, FieldKey {
        case vehicleMake = "vehicleMake"
        case vehicleModel = "vehicleModel"
        case vehiclePlateNumber = "vehicleLicensePlate"
        case confirmVehiclePlateNumber = "vehicleLicensePlateConfirm"

        var modelProperty: String {
            switch self {
            case .confirmVehiclePlateNumber: return "vehiclePlateNumber"
            default:
                return caseName
            }
        }
    }

    private struct Constants {
        static let websiteEntryUrl = "https://www.register2park.com/register"
        static let checkinButtonClass = "btn btn-primary button"
        static let expiryDateFieldId = "end_at2"
    }

    private enum Register2ParkPageManagerPage {
        case unknown
        case appartmentSearch
        case appartmentSearchResult
        case registrationTypeSelection
        case userDetail
        case completion

        var uniqueIdentifier: String {
            switch self {
            case .appartmentSearch: return "Please start by typing in the name of the property you wish to register your vehicle for."
            case .appartmentSearchResult: return "Please select a matching property from below"
            case .userDetail: return "vehicleLicensePlate"
            case .completion: return "print-btn"
            default:
                return "UnIdentifiedPage"
            }
        }
    }

    weak var webView: WKWebView!

    var websiteEntryUrl: String {
        return Constants.websiteEntryUrl
    }

    var guest: Guest?
    var host: Host?

    private var currentPage = Register2ParkPageManagerPage.unknown

    var isManualSaving: Bool { return true }
    var isManualEntry: Bool { return true }

    required init(webView: WKWebView) {
        super.init()

        self.webView = webView
        self.webView.navigationDelegate = self
    }

    func fillDetails() {
        if let host = self.host {
            fillHostDetails(host)
        }

        if let guest = self.guest {
            fillGuestDetails(guest)
            clickFirstButton(forClass: Constants.checkinButtonClass)
        }
    }

    private var savedAppartmentName: String?
    func saveForm(completion: @escaping (Bool) -> Void) {

        getCurrentPage { page in
            switch page {
            case .appartmentSearch:
                self.getValue(forId: HostDetailInputField.appartmentName.fieldId) { name in
                    self.savedAppartmentName = name
                    completion(true)
                }
            // case .appartmentSearchResult:
                // TODO: Identify the selected list and save name
            case .userDetail:
                self.saveForm { (host, guest) in
                    if var guest = guest, guest.vehiclePlateNumber != "" {
                        guest.firstName = guest.vehicleMake
                        guest.lastName = guest.vehicleModel

                        if var host = host {
                            host.appartmentName = self.savedAppartmentName ?? self.host?.appartmentName
                            HostManager.shared.saveHost(host)
                            self.host = host
                            guest.host = host
                        }

                        guest.save()
                        self.guest = guest
                    }

                    completion(true)
                }
            default:
                completion(false)
            }
        }
    }

    private func getCurrentPage(completion: @escaping (Register2ParkPageManagerPage) -> Void) {

        getPageSource { (htmlString) in
            guard let htmlString = htmlString else { completion(.unknown); return }

            var currentPage = Register2ParkPageManagerPage.unknown
            for page in [Register2ParkPageManagerPage.appartmentSearch,
                         Register2ParkPageManagerPage.appartmentSearchResult,
                         Register2ParkPageManagerPage.userDetail,
                         Register2ParkPageManagerPage.completion] {
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
                self.guest?.activePassExpiryDate = Register2ParkPageManager.expiryTimeStringToDate(expiryDateString)
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

extension Register2ParkPageManager: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getCurrentPage { page in
            if page != self.currentPage {
                self.currentPage = page

                switch page {
                case .appartmentSearch, .userDetail: self.fillDetails()
                case .completion: self.parseActivePassMessage()
                default:
                    print("Unknown page!!!!")
                }

                print("Current Page: \(page)")
            }
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if currentPage == .userDetail {
            saveForm { _ in
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
