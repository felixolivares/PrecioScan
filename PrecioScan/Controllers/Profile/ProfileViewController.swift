//
//  ProfileViewController.swift
//  PrecioScan
//
//  Created by Félix Olivares on 10/01/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import DynamicButton
import InteractiveSideMenu
import ALCameraViewController

class ProfileViewController: UIViewController, SideMenuItemContent {

    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = UserManager.shared.getCurrentUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureComponents()
        loadProfilePhoto()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
        self.nameAnimatedControl.setText(text: self.currentUser.name, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.emailAnimatedControl.setText(text: self.currentUser.email, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func hamburgerButtonPressed(_ sender: Any) {
        hamburgerButton.setStyle(.close, animated: true)
        self.showSideMenu()
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        takePhoto()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard nameAnimatedControl.valueTextField.text != "" else {Popup.show(withOK: Warning.Profile.completeName, title: Constants.Popup.Titles.attention, vc: self); return}
        persistentContainer.updateUser(object: self.currentUser, name: nameAnimatedControl.valueTextField.text!, photoName: nil, isLogged: nil, completionHandler: { finished, error in
            guard error == nil else {Popup.show(withError: error! as NSError, vc: self);return}
            if finished {
                FirebaseOperations().updateCurrentUser(displayName: self.nameAnimatedControl.valueTextField.text, photoURL: self.currentUser.photoName)
                Popup.show(message: Constants.Profile.infoUpdated, vc: self)
            }
        })
    }
    
    func configureComponents(){
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: false)
        nameAnimatedControl.setDelegate()
        emailAnimatedControl.setDelegate()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 6.0
    }
    
    func loadProfilePhoto(){
        guard let photoName = self.currentUser.photoName, let photo = FilesManager.shared.getProfileImage(photoName: photoName) else {self.profileImageView.image = UIImage(named: ImageNames.profilePlaceholder);return}
        self.profileImageView.image = photo
    }
    
    func takePhoto(){
        let cropParameters = CroppingParameters.init(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 60, height: 60))
        let cameraViewController = CameraViewController(croppingParameters: cropParameters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] image, asset in
            guard image != nil else{self?.dismiss(animated: true, completion: nil); return}
            let uuid = UUID().uuidString
            print("Photo uuid generated: \(uuid)")
            if FilesManager.shared.saveProfileImage(image: image!, photoName: uuid){
                persistentContainer.updateUser(object: (self?.currentUser)!, name: nil, photoName: uuid, isLogged: nil, completionHandler: { finished, error in
                    guard error == nil else {Popup.show(withError: error! as NSError, vc: self!);return}
                    if finished {
                        self?.profileImageView.image = image
                    }
                })
            } else {
                print("Image not saved")
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
}
