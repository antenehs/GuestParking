//
//  RepeatTimer.swift
//  GuestParking
//
//  Created by Anteneh Sahledengel on 4/1/20.
//  Copyright © 2020 Anteneh Sahledengel. All rights reserved.
//

import Foundation

class RepeatTimer {

    var timer: Timer?
    var interval: TimeInterval
    var handler: () -> Void

    init(interval: TimeInterval, handler: @escaping () -> Void) {
        self.interval = interval
        self.handler = handler
    }

    deinit {
        self.timer?.invalidate()
    }

    func invalidate() {
        self.timer?.invalidate()
    }

    func resume() {
        self.timer = Timer.scheduledTimer(withTimeInterval: interval,
                                          repeats: true, block: { [weak self] _ in
                                            self?.handler()
        })
    }
}
