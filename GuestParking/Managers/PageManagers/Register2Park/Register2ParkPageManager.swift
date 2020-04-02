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
            case .registrationTypeSelection: return "Please select a registration type below:"
            case .userDetail: return "Please enter in your vehicle's information below:"
            case .completion: return "The vehicle listed below is approved"
            default:
                return "UnIdentifiedPage"
            }
        }
    }

    private struct Constants {
        static let websiteEntryUrl = "https://www.register2park.com/register"

        static let searchAppartmentButtonId = "confirmProperty"
        static let confirmAppartmentButtonId = "confirmPropertySelection"
        static let visitorButtonId = "registrationTypeVisitor"
        static let checkUserInButtonId = "vehicleInformation"

        static let messageHandlerName = "messageHandler"

        static let expiryDateFieldId = "end_at2"
    }

    var webView: WKWebView = WKWebView(frame: .zero)

    var websiteEntryUrl: String {
        return Constants.websiteEntryUrl
    }

    var guest: Guest?
    var host: Host?

    private var currentPage = Register2ParkPageManagerPage.unknown
    private var repeatTimer: RepeatTimer?
    private lazy var javascriptMessageHandler: JavascriptMessageHandler = {
        JavascriptMessageHandler() { [weak self] message in
            self?.recievedJavascriptMessage(message)
        }
    }()
    private let userContentController = WKUserContentController()

    override init() {
        super.init()

        let config = WKWebViewConfiguration()
        userContentController.add(javascriptMessageHandler, name: Constants.messageHandlerName)

        let scriptSource = """
            $(document).on('click', '#\(Constants.searchAppartmentButtonId)', function() {
                window.webkit.messageHandlers.\(Constants.messageHandlerName).postMessage({ \"\(Constants.searchAppartmentButtonId)\" : $('#propertyName').val() });
            });

            $(document).on('click', '#\(Constants.confirmAppartmentButtonId)', function() {
                var propertyIdSelected = '';
                // Get selected property
                $('.property:checked').each(function() {
                    propertyIdSelected = $(this).val();
                });

                window.webkit.messageHandlers.\(Constants.messageHandlerName).postMessage({ \"\(Constants.confirmAppartmentButtonId)\" : propertyIdSelected });
            });

            $(document).on('click', '#\(Constants.checkUserInButtonId)', function() {
                window.webkit.messageHandlers.\(Constants.messageHandlerName).postMessage('\(Constants.checkUserInButtonId)');
            });

            function selectProperty(propertyId) {
              $('input.property[value="' + propertyId + '"]')[0].click()
            }
        """

        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)

        config.userContentController = userContentController

        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.navigationDelegate = self

        repeatTimer = RepeatTimer(interval: 2) { [weak self] in self?.repeatTimerCalled() }
    }

    deinit {
        // This is very important to prevent leaks
        userContentController.removeScriptMessageHandler(forName: Constants.messageHandlerName)
        // TODO: Check if timer was started before invalidating
        repeatTimer?.invalidate()
    }

    func fillAppartmentSearchTerm() {
        guard let host = self.host else { return }

        fillHostDetails(host)

        if guest != nil {
            webView.clickFirstButton(forId: Constants.searchAppartmentButtonId)
        }
    }

    func selectAppartmentFromSearch() {
        guard let appartmentId = host?.appartmentID else { return }

        webView.evaluateJavaScript("selectProperty('\(appartmentId)')") { _, _ in }

        if guest != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.webView.clickFirstButton(forId: Constants.confirmAppartmentButtonId)
            }
        }
    }

    func selectParkingType() {
        if guest != nil {
            self.webView.clickFirstButton(forId: Constants.visitorButtonId)
        }
    }

    func fillGuestDetails() {
        if let host = self.host {
            fillHostDetails(host)
        }

        if let guest = self.guest {
            fillGuestDetails(guest)
//            self.webView.clickFirstButton(forId: Constants.checkUserInButtonId)
        }
    }

    private var savedAppartmentSearchTerm: String?
    private var savedAppartmentId: String?

    func saveForm(completion: @escaping (Bool) -> Void) {

        getCurrentPage { page in
            switch page {
            case .userDetail:
                self.saveForm { [weak self] (host, guest) in
                    if var guest = guest, guest.vehiclePlateNumber != "" {
                        guest.firstName = guest.vehicleMake
                        guest.lastName = guest.vehicleModel

                        if var host = host {
                            host.appartmentName = self?.savedAppartmentSearchTerm ?? self?.host?.appartmentName
                            host.appartmentID = self?.savedAppartmentId ?? self?.host?.appartmentID
                            HostManager.shared.saveHost(host)
                            self?.host = host
                            guest.host = host
                        }

                        guest.save()
                        self?.guest = guest
                    }

                    completion(true)
                }
            default:
                completion(false)
            }
        }
    }

    private func recievedJavascriptMessage(_ message: Any) {
        print("Message recieved: \(message)")
        if let dictMessage = message as? [String : String],
            let firstPair = dictMessage.first {
            if firstPair.key == Constants.searchAppartmentButtonId {
                savedAppartmentSearchTerm = firstPair.value
            } else if firstPair.key == Constants.confirmAppartmentButtonId {
                savedAppartmentId = firstPair.value
            }
        } else if (message as? String) == Constants.checkUserInButtonId {
            saveForm { _ in }
        }
    }

    private func getCurrentPage(completion: @escaping (Register2ParkPageManagerPage) -> Void) {

        webView.getPageSource { (htmlString) in
            guard let htmlString = htmlString else { completion(.unknown); return }

            var currentPage = Register2ParkPageManagerPage.unknown
            for page in [Register2ParkPageManagerPage.appartmentSearch,
                         Register2ParkPageManagerPage.appartmentSearchResult,
                         Register2ParkPageManagerPage.registrationTypeSelection,
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

    private func repeatTimerCalled() {
        guard guest != nil || host != nil else { return }

        getCurrentPage { [weak self] page in
            guard let self = self else { return }

            if page != self.currentPage {
                self.currentPage = page

                switch page {
                case .appartmentSearch:
                    self.fillAppartmentSearchTerm()
                case .appartmentSearchResult:
                    self.selectAppartmentFromSearch()
                case .registrationTypeSelection:
                    self.selectParkingType()
                case .userDetail:
                    self.fillGuestDetails()
                case .completion:
                    self.parseActivePassMessage()
                case .unknown:
                    print("Current Page: Unknown page!!!!")
                }

                print("Current Page: \(page)")
            }
        }
    }

    private func parseActivePassMessage(completion: ((String?) -> Void)? = nil) {
        guard currentPage == .completion  else { completion?(nil); return }

        webView.evaluateJavaScript("document.getElementById('\(Constants.expiryDateFieldId)').innerHTML") { [weak self] value, _ in
            if let expiryDateString = value as? String {
                self?.guest?.activePassMessage = "Expires On: \(expiryDateString)"
                self?.guest?.activePassExpiryDate = Register2ParkPageManager.expiryTimeStringToDate(expiryDateString)
                self?.guest?.save()
                if let guest = self?.guest {
                    self?.completedCheckingIn(guest)
                }
            }
            completion?(value as? String)
        }
    }

    // MARK: - Helpers

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
        // First load
        if guest != nil || host != nil {
            repeatTimer?.resume()
        }
    }
}
