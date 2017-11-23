//
//  UserManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 07/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreData
import JSQCoreDataKit

class UserManager: NSObject {
    static let shared = UserManager()
    
    static var isLoggedIn: Bool? = false
    static var currentUser: User!
    
    private override init(){
        super.init()
        UserManager.configure()
    }
    
    static func configure(){
        isLoggedIn = restoreUserIsLoggedIn()
    }
    
    static func setCurrentUser(user: User){
        self.currentUser = user 
        //print("Current user: \(currentUser.email)")
    }
    
    public func verifyUserIsLogged(vc: UIViewController){
        if !UserManager.isLoggedIn!{
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if !(topController is LoginViewController){
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                    vc.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    public func logIn(email: String){
        self.saveUserIsLoggedIn(withValue: true)
        self.getCurrentUserAndSaveStatus(isLogged: true)
    }
    
    public func logOut(){
        self.saveUserIsLoggedIn(withValue: false)
        self.getCurrentUserAndSaveStatus(isLogged: false)
    }
    
    private func saveUserIsLoggedIn(withValue completed: Bool? = true){
        UserDefaults.standard.setValue(completed, forKey: Constants.User.Keys.isLoggedIn)
        UserManager.isLoggedIn = completed
    }
    
    private static func restoreUserIsLoggedIn() -> Bool{
        guard let temp = UserDefaults.standard.object(forKey: Constants.User.Keys.isLoggedIn) as? Bool else { return false}
        return temp
    }
    
    private func getCurrentUserAndSaveStatus(isLogged: Bool){
        let FRUser = Auth.auth().currentUser
        if let user = FRUser{
            CoreDataManager.shared.user(withEmail: user.email){ users, error in
                if (users?.count)! > 0 {
                    if let finalUser = users?.first {
                        CoreDataManager.shared.updateUser(object: finalUser, email: finalUser.email, password: finalUser.password, name: finalUser.name, photoName: finalUser.photoName, isLogged: isLogged){ finished, error in
                            UserManager.currentUser = finalUser
                            print("Current user: \(String(describing: finalUser.email)) - Is Logged: \(String(describing: finalUser.isLogged))")
                        }
                    }
                } else {
                    CoreDataManager.shared.saveUser(email: (FRUser?.email)!, password: nil, name: (FRUser?.displayName)!, photoName: nil, isLogged: true){ user, error in
                        UserManager.currentUser = user
                        print("User saved - Current user: \(String(describing: user?.email)) - Is Logged: \(String(describing: user?.isLogged))")
                    }
                }
            }
        }
    }
}


