//
//  CreateStoreViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/10/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import PMSuperButton
import CoreData
import JSQCoreDataKit

protocol CreateStoreViewControllerDelegate{
    func storeSaved(store: Store)
}

class CreateStoreViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var storeNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var locationNameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var saveButton: PMSuperButton!
    
    var stack: CoreDataStack!
    var fetchResultController: NSFetchedResultsController<Store>!
    var stores: [Store] = []
    
    var delegate: CreateStoreViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        CoreDataManager.shared.stores{stack, stores, error in
            guard error != nil else {return}
            self.stack = stack
            self.stores = stores!
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard storeNameAnimatedControl.valueTextField.text != "", locationNameAnimatedControl.valueTextField.text != "" else{Popup.show(withOK: Warning.CreateStore.completeAllFieldsText, vc: self); return}
        CoreDataManager.shared.saveStore(name: storeNameAnimatedControl.valueTextField.text!, location: locationNameAnimatedControl.valueTextField.text!, information: nil){ storeSaved, error in
            if let store = storeSaved {
                Popup.show(withCompletionMessage: Constants.CreateStore.Popup.storeSaved, vc: self){ _ in
                    self.delegate?.storeSaved(store: store)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func configure(){
        storeNameAnimatedControl.setDelegate()
        locationNameAnimatedControl.setDelegate()
    }
}
