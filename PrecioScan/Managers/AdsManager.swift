//
//  AdsManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 26/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsManager: NSObject {

    static let shared = AdsManager()
    private let adRequest = GADRequest()
    
    public func getRequest() -> GADRequest {
        adRequest.testDevices = ["83e00fd76a3f30b0f778eff61eb2718a", kGADSimulatorID]
        return adRequest
    }
}
