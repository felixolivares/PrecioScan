//
//  ArticleFoundDetailViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 3/27/19.
//  Copyright © 2019 Felix Olivares. All rights reserved.
//

import UIKit

class ArticleFoundDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    var articleSaved: Article!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("[ArticleFound] - Article saved: \(String(describing: articleSaved.code))")
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    

}
