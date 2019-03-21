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
import GoogleMobileAds
import MKDropdownMenu

class ProfileViewController: UIViewController, SideMenuItemContent {

    @IBOutlet weak var hamburgerButton: DynamicButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var emailAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var statesMenu: MKDropdownMenu!
    @IBOutlet weak var underlineState: UIView!
    @IBOutlet weak var cityAnimatedControl: AnimatedInputControl!
    @IBOutlet weak var stateLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateDisplayName: UILabel!
    
    var currentUser: User!
    var interstitialAd: GADInterstitial!
    var stateSelected: String!
    var dropDownIsOpen: Bool = false
    let componentTitles = States().allStates()
    var displayStateName = Constants.CreateStore.selectStateText
    var stateIsSelected: Bool = false
    let paragraphStyle = NSMutableParagraphStyle.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitialAd = createAndLoadInterstitial()
        configureMenu()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureComponents()
        loadProfilePhoto()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dropDownIsOpen{
            statesMenu.closeAllComponents(animated: false)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.setStyle(.hamburger, animated: true)
        loadUserInformation()
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
        guard nameAnimatedControl.valueTextField.text != "", self.stateSelected != "", cityAnimatedControl.valueTextField.text != "" else {Popup.show(withOK: Warning.Profile.completeFields, title: Constants.Popup.Titles.attention, vc: self); return}
        persistentContainer.updateUser(object: self.currentUser, name: nameAnimatedControl.valueTextField.text!, photoName: nil, isLogged: nil, state: self.stateSelected, city: cityAnimatedControl.valueTextField.text!, completionHandler: { finished, error in
            guard error == nil else {Popup.show(withError: error! as NSError, vc: self);return}
            if finished {
                FirebaseOperations().updateUserLoggedIn(displayName: self.nameAnimatedControl.valueTextField.text, photoURL: self.currentUser.photoName, state: self.stateSelected, city: self.cityAnimatedControl.valueTextField.text!)
                Popup.show(message: Constants.Profile.infoUpdated, vc: self)
            }
        })
    }
    
    func configureComponents(){
        self.currentUser = UserManager.shared.getCurrentUser()
        UserManager.shared.verifyUserIsLogged(vc: self)
        hamburgerButton.setStyle(.hamburger, animated: false)
        nameAnimatedControl.setDelegate()
        emailAnimatedControl.setDelegate()
        cityAnimatedControl.setDelegate()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 6.0
    }
    
    func configureMenu(){
        statesMenu.dropdownShowsTopRowSeparator = true
        statesMenu.dropdownShowsBottomRowSeparator = false
        statesMenu.dropdownShowsBorder = true
        statesMenu.backgroundDimmingOpacity = 0
        statesMenu.componentTextAlignment = .left
    }
    
    func createAndLoadInterstitial() -> GADInterstitial{
        let interstitial = GADInterstitial(adUnitID: testingAds ? Constants.Admob.interstitialTestId : Constants.Admob.interstitialListDetailId)
        interstitial.delegate = self
        interstitial.load(AdsManager.shared.getRequest())
        return interstitial
    }
    
    func showInterstitial(){
        guard !UserManager.shared.userIsSuscribed() else {_ = self.navigationController?.popViewController(animated: true);return}
        if interstitialAd.isReady {
            interstitialAd.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func loadProfilePhoto(){
        guard let photoName = self.currentUser.photoName, let photo = FilesManager.shared.getProfileImage(photoName: photoName) else {self.profileImageView.image = UIImage(named: ImageNames.profilePlaceholder);return}
        self.profileImageView.image = photo
    }
    
    func loadUserInformation(){
        self.emailAnimatedControl.setText(text: self.currentUser.email, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.nameAnimatedControl.setText(text: self.currentUser.name, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.stateLabelCenterConstraint.constant = -20
                self.stateDisplayName.text = self.currentUser.state
                self.stateSelected = self.currentUser.state
                UIView.animate(withDuration: 0.15, animations: {
                    self.view.layoutIfNeeded()
                    self.underlineState.backgroundColor = UIColor(spadeGreen)
                }) { (completed) in
                    UIView.animate(withDuration: 0.8, animations: {
                        self.stateDisplayName.alpha = 1
                    })
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.cityAnimatedControl.setText(text: self.currentUser.city, animated: true)
                }
            }
        }
    }
    
    func takePhoto(){
        let cropParameters = CroppingParameters.init(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 60, height: 60))
        let cameraViewController = CameraViewController(croppingParameters: cropParameters, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] image, asset in
            guard image != nil else{self?.dismiss(animated: true, completion: nil); self?.showInterstitial();return}
            let uuid = UUID().uuidString
            print("Photo uuid generated: \(uuid)")
            if FilesManager.shared.saveProfileImage(image: image!, photoName: uuid){
                persistentContainer.updateUser(object: (self?.currentUser)!, name: nil, photoName: uuid, isLogged: nil, state: nil, city: nil, completionHandler: { finished, error in
                    guard error == nil else {Popup.show(withError: error! as NSError, vc: self!);return}
                    if finished {
                        self?.profileImageView.image = image
                    }
                })
            } else {
                print("Image not saved")
            }
            self?.dismiss(animated: true, completion: nil)
            self?.showInterstitial()
        }
        present(cameraViewController, animated: true, completion: nil)
    }
}

extension ProfileViewController: GADInterstitialDelegate{
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        _ = self.navigationController?.popViewController(animated: true)
        interstitialAd = createAndLoadInterstitial()
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Ad received")
    }
}

//MARK: - MKDropdown Data Source
extension ProfileViewController: MKDropdownMenuDataSource{
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return componentTitles.count
    }
}

//MARK: - MKDropdown Delegate Methods
extension ProfileViewController: MKDropdownMenuDelegate{
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, widthForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, shouldUseFullRowWidthForComponent component: Int) -> Bool {
        return false
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForComponent component: Int) -> NSAttributedString? {
        let titleColor = self.stateIsSelected ? UIColor.black : UIColor(titleGray)
        let titleFont = self.stateIsSelected ? UIFont(name: Font.ubuntuBoldFont, size: 17.0)! : UIFont(name: Font.ubuntuMediumFont, size: 14.0)!
        return NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: titleFont, NSAttributedString.Key.foregroundColor: titleColor!, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: componentTitles[row], attributes:[NSAttributedString.Key.font: UIFont(name: Font.ubuntuRegularFont, size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        dropdownMenu.closeAllComponents(animated: false)
        self.displayStateName = componentTitles[row]
        self.stateSelected = componentTitles[row]
        self.underlineState.backgroundColor = UIColor(spadeGreen)
        self.stateIsSelected = true
        self.stateDisplayName.text = componentTitles[row]
        dropdownMenu.reloadAllComponents()
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didOpenComponent component: Int) {
        self.dropDownIsOpen = true
        self.view.endEditing(true)
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didCloseComponent component: Int) {
        self.dropDownIsOpen = false
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, backgroundColorForRow row: Int, forComponent component: Int) -> UIColor? {
        return UIColor(solitudeGray)
    }
}
