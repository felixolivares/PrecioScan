//
//  FilesManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 17/11/17.
//  Copyright © 2017 Felix Olivares. All rights reserved.
//

import UIKit

class FilesManager: NSObject {
    static let shared = FilesManager()
    static var photosPath: URL!
    static var profilePhotoPath: URL!
    static var photosCount = 0
    static var profilePhotoCount = 0
    let fileManager = FileManager.default
    
    private override init(){
        super.init()
        self.configure()
    }
    
    func configure(){
        self.createPhotosFolder()
        self.createProfilePhotoFolder()
    }
    
    private func createPhotosFolder(){
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent(Constants.Files.photosFolder)
            
            var isDir: ObjCBool = true
            FilesManager.photosPath = filePath
            print("Document directory is \(filePath)")
            if fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir) {
                if isDir.boolValue{
                    
                    let fm = FileManager.default
                    let path = filePath.path
                    
                    do {
                        let items = try fm.contentsOfDirectory(atPath: path)
                        FilesManager.photosCount = items.count
                        print("How many items in folder: \(items.count)")
                        for item in items {
                            print("Found \(item)")
                        }
                    } catch let error as NSError{
                        // failed to read directory – bad permissions, perhaps?
                        print(error.localizedDescription)
                    }
                }
            }else{
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func createProfilePhotoFolder(){
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = tDocumentDirectory.appendingPathComponent(Constants.Files.profilePhotoFolder)
            
            var isDir: ObjCBool = true
            FilesManager.profilePhotoPath = filePath
            print("Profile photo directory is \(filePath)")
            if fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir) {
                if isDir.boolValue{
                    
                    let fm = FileManager.default
                    let path = filePath.path
                    
                    do {
                        let items = try fm.contentsOfDirectory(atPath: path)
                        FilesManager.profilePhotoCount = items.count
                        print("How many items in profile folder: \(items.count)")
                        for item in items {
                            print("Found \(item)")
                        }
                    } catch let error as NSError{
                        // failed to read directory – bad permissions, perhaps?
                        print(error.localizedDescription)
                    }
                }
            }else{
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func saveImage (image: UIImage, photoName: String) -> Bool{
        let pngImageData = image.pngData()
        let path = FilesManager.photosPath.appendingPathComponent("\(photoName + Constants.Files.photoExtension)")
        return FileManager.default.createFile(atPath: path.path, contents: pngImageData, attributes: nil)
    }
    
    public func saveProfileImage (image: UIImage, photoName: String) -> Bool{
        let pngImageData = image.pngData()
        let path = FilesManager.profilePhotoPath.appendingPathComponent("\(photoName + Constants.Files.photoExtension)")
        return FileManager.default.createFile(atPath: path.path, contents: pngImageData, attributes: nil)
    }
    
    public func getProfileImage(photoName: String) -> UIImage? {
        let path = FilesManager.profilePhotoPath.appendingPathComponent("\(photoName + Constants.Files.photoExtension)")
        if fileManager.fileExists(atPath: path.path){
            print("Profile image exists!")
        }else{
            print("Profile image dos not exists :(")
        }
        return UIImage.init(contentsOfFile: path.path)
    }
    
    public func deleteImage(imageName: String) -> Bool{
        let photoPath = FilesManager.photosPath.appendingPathComponent("\(imageName + Constants.Files.photoExtension)")
        do {
            try fileManager.removeItem(atPath: photoPath.path)
            return true
        } catch let error as NSError{
            print(error.localizedDescription)
            return false
        }
    }
    
    public func deleteAllImages(vc: UIViewController, completionHandler: @escaping(Bool) -> Void){
        do{
            var photosDeleted = 0
            let filePaths = try fileManager.contentsOfDirectory(atPath: FilesManager.photosPath.path)
            for filePath in filePaths{
                try fileManager.removeItem(atPath: FilesManager.photosPath.path + "/" + filePath)
                photosDeleted += 1
            }
            print("Success phtos deleted: \(photosDeleted)")
            if photosDeleted > 0 {
                Popup.show(message: Constants.Configuration.photosDeletedMessage, vc: vc)
                completionHandler(true)
            } else {
                Popup.show(message: Constants.Configuration.noPhotosToDeleteMessage, vc: vc)
                completionHandler(false)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    public func verifyPhotoExists(name: String) -> UIImage? {
        let photoPath = FilesManager.photosPath.appendingPathComponent("\(name).png")
        var isDir: ObjCBool = true
        guard fileManager.fileExists(atPath: photoPath.path, isDirectory: &isDir) else {return nil}
        if let image = UIImage.init(contentsOfFile: photoPath.path) {
            return image
        } else {
            return nil
        }
    }
    
    public func countPhotos(completionHandler:@escaping(Int) -> Void){
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath =  tDocumentDirectory.appendingPathComponent(Constants.Files.photosFolder)
            var isDir: ObjCBool = true
            if fileManager.fileExists(atPath: filePath.path, isDirectory: &isDir) {
                if isDir.boolValue{
                    
                    let fm = FileManager.default
                    let path = filePath.path
                    
                    do {
                        let items = try fm.contentsOfDirectory(atPath: path)
                        FilesManager.photosCount = items.count
                        completionHandler(items.count)
                    } catch let error as NSError{
                        // failed to read directory – bad permissions, perhaps?
                        print(error.localizedDescription)
                        completionHandler(0)
                    }
                }
            }
        }
    }
}
