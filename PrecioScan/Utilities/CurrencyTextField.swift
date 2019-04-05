//
//  CurrencyTextField.swift
//  PrecioScan
//
//  Created by Félix Olivares on 3/28/19.
//  Copyright © 2019 Felix Olivares. All rights reserved.
//

import UIKit

class CurrencyTextField: UITextField {

    var string: String { return text ?? "" }
    var decimal: Decimal {
        return string.decimal /
            pow(10, Formatter.currency.maximumFractionDigits)
    }
    var decimalNumber: NSDecimalNumber { return decimal.number }
    var doubleValue: Double { return decimalNumber.doubleValue }
    var integerValue: Int { return decimalNumber.intValue   }
    let maximum: Decimal = 999_999_999.99
    private var lastValue: String?
    override func willMove(toSuperview newSuperview: UIView?) {
        // you can make it a fixed locale currency if needed
        // Formatter.currency.locale = Locale(identifier: "pt_BR") // or "en_US", "fr_FR", etc
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        keyboardType = .numberPad
        textAlignment = .center
        editingChanged(self)
    }
    override func deleteBackward() {
        text = String(string.digits.dropLast())
        editingChanged(self)
    }
    @objc func editingChanged(_ textField: UITextField) {
        guard decimal <= maximum else {
            text = lastValue
            return
        }
        text = Formatter.currency.string(for: decimal)
        lastValue = text
    }
}

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}
extension Formatter {
    static let currency = NumberFormatter(numberStyle: .currency)
}
extension String {
    var digits: String { return filter(("0"..."9").contains) }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }
}
extension Decimal {
    var number: NSDecimalNumber { return NSDecimalNumber(decimal: self) }
}
