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
    let fileManager = FileManager.default
    
    private override init(){
        super.init()
        self.configure()
    }
    
    func configure(){
        self.createPhotosFolder()
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
    
    public func saveImage (image: UIImage, photoName: String) -> Bool{
        let pngImageData = UIImagePNGRepresentation(image)
        let path = FilesManager.photosPath.appendingPathComponent("\(photoName).png")
        return FileManager.default.createFile(atPath: path.path, contents: pngImageData, attributes: nil)
    }
    
    public func deleteImage(imageName: String) -> Bool{
        let photoPath = FilesManager.photosPath.appendingPathComponent("\(imageName).png")
        do {
            try fileManager.removeItem(atPath: photoPath.path)
            return true
        } catch let error as NSError{
            print(error.localizedDescription)
            return false
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
}
