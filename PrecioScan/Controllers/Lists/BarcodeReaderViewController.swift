//
//  BarcodeReaderViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 3/26/19.
//  Copyright © 2019 Felix Olivares. All rights reserved.
//

import UIKit

class BarcodeReaderViewController: UIViewController {

    @IBOutlet weak var barcodeReader: BarcodeReader!
    @IBOutlet weak var barcodeLineScanner: BarcodeLine!
    
    var store: Store!
    var list: List!
    private var barcodeIsRead: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barcodeLineScanner.startAnimation()
    }
    


}
