//
//  LastestPhotosViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 21/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit
import CoreData

/*
 This represents the main scene. The Tamagotchi is shown here.
 The user should be triggered to take a picture.
 */
class LatestPhotosViewController: UITableViewController {
    
    var images: [StoredImage]?
    
    var persistentDataManager: PersistentDataManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(persistentDataManager != nil){
            print("Loading stored images")
            images = persistentDataManager!.retrieveImages()
        }
        
    }
    
    // number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(images != nil){
            print("Return number of images stored: \(images!.count)")
        return images!.count
        }else{
            images = persistentDataManager!.retrieveImages()
        }
        return images!.count
    
    }
    
    // how does a row look like?
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(images == nil){
            images = persistentDataManager!.retrieveImages()
        }
        
        var cell: UITableViewCell
        if let dequeueCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = dequeueCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell.textLabel?.text = images![indexPath.row].getDescr()
        cell.imageView?.image = persistentDataManager?.retrieveImage(forKey: images![indexPath.row].getName())
        return cell
        
    }
}
