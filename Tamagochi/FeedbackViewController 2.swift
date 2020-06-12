//
//  FeedbackViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 11/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

/*
 This represents the feedback scene after taking a photo.
 The sees now if the picture was accepted.
 */

class FeedbackViewController : UIViewController {
    
    @IBAction func closeFeedback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var inputImage : UIImage?
    private var imageClassification : ImageClassification!
    private var status = ImageStatus.unknown
    
    // CoreData
    var container: NSPersistentContainer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = GlobalSettings.colors[0]
        bite1.alpha = 0
        bite2.alpha = 0
        bite3.alpha = 0
        bite4.alpha = 0
        
        imageClassification = ImageClassification(controllerToNotify: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if inputImage != nil{
            // view image (maybe not required)
            imageViewer.image = inputImage!
            // run classification asynchroneous
            imageClassification.updateClassifications(for: inputImage!)
        }else{
            print("ERROR: No image passed for classification!")
        }
    }
    
    
    func updateStatus(status : ImageStatus){
        self.status = status
        
        switch status{
        case .processing:
            statusLabel.text = "Classification..."
        case .unknown:
            statusLabel.text = "Unknow status..."
        case .healthy:
            statusLabel.text = "The food is healty!"
        case .unhealthy:
            statusLabel.text = "The food in unhealthy!"
        case .classified:
            statusLabel.text = "Classification finished..."
        case .classificationFailed:
            statusLabel.text = "Classification failed..."
        }
    }
    
    
    func healthyImageRecognized(){
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
            
            self.bite1.alpha = 1
            
        }, completion: { (position) in
            
            
            UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                
                self.bite2.alpha = 1
                self.titleLabel.text = "Yummy!"
                self.titleLabel.textColor = UIColor.green
                
            }, completion: { (position) in
                
                
                UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                    
                    self.bite3.alpha = 1
                    
                    
                }, completion: { (position) in
                    
                    
                    UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                        
                        self.bite4.alpha = 1
                        
                    }, completion: { (position) in
                        
                        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                            
                            self.imageViewer.alpha = 0
                            
                        }, completion: { (position) in
                            
                            UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            }, completion: nil)
                        })
                    })
                })
            })
        })
    }
    
    func unhealthyImageRecognized(){
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
            
            self.bite1.alpha = 1
            
        }, completion: { (position) in
            
            
            UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                
                self.titleLabel.text = "So bad!"
                self.titleLabel.textColor = UIColor.red
                self.statusLabel.text = "You should try eating something different"
                
            }, completion: nil)
        })
    }

    func imageNotRecognized(){
        myAlert(title: "Error", message: "Image not recognized")
    }
    
    func myAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.titleLabel.text = "Error!"
        self.statusLabel.text = ""
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var bite1: UIImageView!
    @IBOutlet weak var bite2: UIImageView!
    @IBOutlet weak var bite3: UIImageView!
    @IBOutlet weak var bite4: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}


// Enums, Helpers

enum ImageStatus : String {
    case unknown
    case processing
    case healthy
    case unhealthy
    case classified
    case classificationFailed
}
