//
//  CoreDataAccess.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 20/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class PersistentDataManager{
    
    let appDelegate: AppDelegate
    let managedContext: NSManagedObjectContext
    
    let fileManager = FileManager.default
    
    init(){
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.managedContext = appDelegate.persistentContainer.viewContext
        
    }
    
    
    // MARK: - File Access
    func saveImage(image: UIImage, status: ImageType, descr: String) throws -> String{
        
        if (status != ImageType.food && status != ImageType.water){
            print("Cannot save unhealthy image! \(status)")
            throw TamagotchiError.cannotSaveUnhealthyImage
        }
        
        let name = String(Date().timeIntervalSince1970.description.hashValue)
        print(name)
        
        if let filePath = filePath(forKey: name) {
            do  {
                try image.pngData()!.write(to: filePath, options: .atomic)
            } catch let err {
                print("Saving file resulted in error: ", err)
            }
        }
        
        saveImageToCoreData(name: name, status: status, descr: descr)
        
        return name
    }
    
    func retrieveImage(forKey: String) -> UIImage? {
        
        if let filePath = filePath(forKey: forKey),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData) {
            return image
        }
        return nil
    }
    
    
    func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    
    
    
    // MARK: - CoreData access
    
    func initHealthStatus(){
        let currentHealthStatusEntity = NSEntityDescription.entity(forEntityName: "HealthStatus", in: managedContext)!
        
        let currentHealthStatus = NSManagedObject(entity: currentHealthStatusEntity, insertInto: managedContext)
        
        // 4 hours ago
        currentHealthStatus.setValue(Calendar.current.date(byAdding: .hour, value: -4, to: Date()), forKey: "lastPhotoFood")
        currentHealthStatus.setValue(Calendar.current.date(byAdding: .hour, value: -4, to: Date()), forKey: "lastPhotoWater")
        currentHealthStatus.setValue(Date(), forKey: "dateChallengeStarted")
        
        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Error while writing CoreData! \(error.userInfo)")
        }
        print("Initialized CoreData HealthStatus entry")
    }
    
    func readHealthStatus() -> [String: Int]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        
        var healthValues: [String: Int] = [:]
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            let multiplier: Double = (100 / (12*60*60))
            for data in result as! [NSManagedObject] {
                
                
                // FOOD
                print("lastPhotoFood ", data.value(forKey: "lastPhotoFood") as! Date)
                
                let dateLastPhoto = data.value(forKey: "lastPhotoFood") as! Date
                let timeSinceLastFood : TimeInterval = dateLastPhoto.distance(to: Date())
                print("timeSinceLastFood", timeSinceLastFood)
                healthValues["hungry"] = 100 - Int(Double(timeSinceLastFood) * multiplier)
                
                print("hungry level \(String(describing: healthValues["hungry"]))")
                
                // dies after 24h without food
                if (timeSinceLastFood > (12*60*60)) && (timeSinceLastFood < (24*60*60)) {
                    healthValues["hungry"] = 5
                }
                if (timeSinceLastFood > (24*60*60)){
                    healthValues["hungry"] = 0
                }
                
                // WATER
                print("lastPhotoWater ", data.value(forKey: "lastPhotoWater") as! Date)
                let dateLastPhotoWater = data.value(forKey: "lastPhotoWater") as! Date
                let timeSinceLastWater : TimeInterval = dateLastPhotoWater.distance(to: Date())
                print("timeSinceLastWater", timeSinceLastWater)
                healthValues["thirsty"] = 100 - Int(Double(timeSinceLastWater) * multiplier)
                
                print("water level \(String(describing: healthValues["thirsty"]))")
                
                // dies after 24h without food
                if (timeSinceLastWater > (12*60*60)) && (timeSinceLastWater < (24*60*60)) {
                    healthValues["thirsty"] = 5
                }
                if (timeSinceLastFood > (24*60*60)){
                    healthValues["thirsty"] = 0
                }
                
                var daysInChallenge = daysBetween(start: data.value(forKey: "dateChallengeStarted") as! Date, end: Date())
                
                //minutes
                if(GlobalSettings.demoMode){
                    daysInChallenge = minutesBetween(start: data.value(forKey: "dateChallengeStarted") as! Date, end: Date())
                }
                
                healthValues["daysInChallenge"] = daysInChallenge
                
            }
        } catch let error as NSError {
            print("Error while reading CoreData! \(error.userInfo)")
        }
        return healthValues
    }
    
    // TODO decided how much to increase, set date...
    func updateLastPhotoDate(forType: ImageType){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthStatus")
        fetchRequest.fetchLimit = 1
        
        do{
            let results = try managedContext.fetch(fetchRequest)
            if results.count != 0 {
                let objectToUpdate = results[0] as! NSManagedObject
                // TODO: Do the calcuation depending on the date
                switch forType{
                case .food:
                    objectToUpdate.setValue(Date(), forKey: "lastPhotoFood")
                case .water:
                    objectToUpdate.setValue(Date(), forKey: "lastPhotoWater")
                case .unknown:
                    print("Error, cannot set date value!")
                }
            }else{
                throw TamagotchiError.coreDataNotInitialized
            }
            
        } catch {
            print("Could not update CoreData entry! Try to init now... \(error)")
            initHealthStatus()
        }
        
        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Error while writing CoreData! \(error.userInfo)")
        }
    }
    
    
    func saveImageToCoreData(name: String, status: ImageType, descr: String){
        let imageTaken = NSEntityDescription.entity(forEntityName: "FoodImage", in: managedContext)!
        
        let imageObject = NSManagedObject(entity: imageTaken, insertInto: managedContext)
        imageObject.setValue(name, forKey: "name")
        imageObject.setValue(descr, forKey: "descr")
        imageObject.setValue(Date(), forKey: "date")
        switch status{
        case .food:
            imageObject.setValue("food", forKey: "type")
        case .water:
            imageObject.setValue("water", forKey: "type")
        default:
            print("Could not save image")
            return
        }
        
        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Error while writing updated image dates to CoreData! \(error.userInfo)")
        }
        
        updateLastPhotoDate(forType: status)
        
        print("Stored image and saved path in CoreData")
    }
    
    func retrieveImages() -> [StoredImage] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodImage")
        
        var images = [StoredImage]()
        
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                
                images.append(
                    StoredImage(
                        name: data.value(forKey: "name") as! String,
                        date: data.value(forKey: "date") as! Date,
                        type: data.value(forKey: "type") as! String,
                        descr: data.value(forKey: "descr") as! String)
                )
            }
        } catch let error as NSError {
            print("Error while reading CoreData! \(error.userInfo)")
        }
        return images
    }
    
    //MARK:- daysBetween
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    //MARK:- minutesBetween
    func minutesBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: start, to: end).minute!
    }
    
}
