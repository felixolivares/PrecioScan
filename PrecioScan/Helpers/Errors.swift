//
//  Errors.swift
//  PrecioScan
//
//  Created by Félix Olivares on 12/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

public enum ErrorTitle: String {
    case warning  = "Warning"
    case failed   = "Failed"
    case attention = "Attention"
    case error    = "Error"
}

public enum ErrorType: Int {
    
    case unknown = 1
    case timeOut = 2
    case notConnectedToInternet = 3
    case cannotSaveInCoreData = 4
    case cannotDownloadImage = 5
    
    func localizedUserInfo() -> [String: String] {
        var localizedDescription: String? = ""
        var localizedFailureReasonError: String? = ""
        let localizedRecoverySuggestionError: String? = ""
        
        switch self {
        case .unknown:
            localizedDescription = NSLocalizedString("Unknown error", comment: "Unknown error")
            localizedFailureReasonError = ErrorTitle.failed.rawValue
        case .timeOut:
            localizedDescription = NSLocalizedString("Request timed out", comment: "Request time out")
            localizedFailureReasonError = ErrorTitle.failed.rawValue
        case .notConnectedToInternet:
            localizedDescription = NSLocalizedString("You are not connected to the internet", comment: "No Internet Connection")
            localizedFailureReasonError = ErrorTitle.error.rawValue
        case .cannotSaveInCoreData:
            localizedDescription = NSLocalizedString("Can't save locally", comment: "Can't save story to core data")
            localizedFailureReasonError = ErrorTitle.error.rawValue
        case .cannotDownloadImage:
            localizedDescription = NSLocalizedString("Cannot download image", comment: "Can't download image")
            localizedFailureReasonError = ErrorTitle.error.rawValue
        }
        return [
            NSLocalizedDescriptionKey: localizedDescription!,
            NSLocalizedFailureReasonErrorKey: localizedFailureReasonError!,
            NSLocalizedRecoverySuggestionErrorKey: localizedRecoverySuggestionError!
        ]
    }
}

public let projectErrorDomain = "PrecioScan"

extension NSError {
    
    public convenience init(type: ErrorType) {
        self.init(domain: projectErrorDomain, code: type.rawValue, userInfo: type.localizedUserInfo())
    }
}

