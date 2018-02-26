//
//  GlobalFunctions.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/30/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GlobalFunctions {
    
    static let shared = GlobalFunctions()
    
    //Dropdown menu color
    static let dropDownMenuColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
    //VK Blue Color
    static let vkNavBarColor = UIColor(red:0.35, green:0.52, blue:0.71, alpha:1.0)
    //Blue color
    let blueButtonColor = UIColor(red:0.04, green:0.38, blue:1.00, alpha:1.0).cgColor
    //Red color
    let redButtonColor = UIColor(red:0.93, green:0.11, blue:0.14, alpha:1.0).cgColor
    
    
    //Save audio info to Realm
    func createSavedAudio(title: String, artist: String, duration: Int, url: URL) {
        let savedAudio = SavedAudio()
        savedAudio.title = title
        savedAudio.artist = artist
        savedAudio.duration = duration
        savedAudio.url = url.absoluteString
        
        let realm = try! Realm()
        try! realm.write { realm.add(savedAudio)}
    }
    
    func urlToHTMLString(url: String, completionHandler: @escaping (_ html: String?, _ error: String?) -> ()) {
        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let webURL = URL(string: url) else {
            completionHandler(nil, "Invalid URL")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [] in
            do {
                let myHTMLString = try String(contentsOf: webURL, encoding: .utf8)
                completionHandler(myHTMLString, nil)
            } catch let error {
                print("Error: \(error)")
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    //For volume bar
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func folderSize() -> UInt {
    
        let folderPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("Downloads")
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            return 0
        }
        
        let filesArray: [String] = try! FileManager.default.subpathsOfDirectory(atPath: folderPath.path)
        var fileSize:UInt = 0
        
        for fileName in filesArray {
            let filePath = folderPath.path + "/" + fileName
            let fileDictionary:NSDictionary = try! FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            fileSize += UInt(fileDictionary.fileSize())
        }
        
        return fileSize
    }
    
    func getFriendlyCacheSize() -> String {
        let size = folderSize()
        if size == 0 {
            return "Zero KB"
        }
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}

