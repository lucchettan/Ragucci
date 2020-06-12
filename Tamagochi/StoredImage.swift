//
//  StoredImage.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 20/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation


class StoredImage {
    var type: ImageType!
    var name: String!
    var date: Date!
    var descr: String!
    
    
    init(name: String, date: Date, type: String, descr: String) {
        self.name = name
        self.date = date
        self.descr = descr
        
        switch type{
        case ImageType.food.rawValue:
            self.type = ImageType.food
        case ImageType.water.rawValue:
            self.type = ImageType.food
        case ImageType.unknown.rawValue:
            self.type = ImageType.unknown
        default:
            break
        }
    }
    
    func getName() -> String{
        return self.name
    }
    
    func getDescr() -> String{
        return self.descr
    }
    
    func getType() -> ImageType{
        return self.type
    }
    
    func getDate() -> Date{
        return self.date
    }
    
}
