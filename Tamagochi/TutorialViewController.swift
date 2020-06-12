//
//  TutorialViewController.swift
//  Tamagochi
//
//  Created by Alessandro Palermo on 15/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController : UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = GlobalSettings.colors[0]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // TO_DO: Ask for notifications
        
        //permission for notifications
        let manager = NotificationManager()
        manager.requestAuthorization()
        
    }
    
    @IBAction func exitTutorial(_ sender: UIButton) {
        
        // Closes the tutorial page
        dismiss(animated: true, completion: nil)
    }
}
