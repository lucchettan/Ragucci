//
//  GlobalSettings.swift
//  Tamagochi
//
//  Created by Alessandro Palermo on 12/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UIKit

public class GlobalSettings {
    
    static let colors = [UIColor(rgb: 0x20E1D1), UIColor(rgb: 0x96C0FF), UIColor(rgb: 0x7DB1FF), UIColor(rgb: 0xC1A772), UIColor.white, UIColor(rgb: 0xFFAD08), UIColor.black]
    static let debugMode: DebugMode = .disabled
    static let demoMode = false
    
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

// Enums, Helpers

enum ImageStatus : String {
    case unknown
    case processing
    case healthy
    case unhealthy
    case classified
    case classificationFailed
    case lowConfidence
    case water
}

enum ImageType: String {
    case water
    case food
    case unknown
}

enum TamagotchiError: Error{
    case coreDataNotInitialized
    case cannotSaveUnhealthyImage
    case saveImageError
}

enum DebugMode: String{
    case acceptWater
    case acceptFood
    case rejectPhoto
    case lowConfidence
    case disabled
}
