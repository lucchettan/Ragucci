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

class FeedbackViewController : UILoggingViewController {
    
    @IBAction func closeFeedback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var inputImage : UIImage?
    var coreDataAccess: PersistentDataManager?
    var homeViewController : HomeViewController?
    private var imageClassification : ImageClassification!
    private var status = ImageStatus.unknown
    private var recognizedObject = ""
    
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
        case .classificationFailed:
            statusLabel.text = "Classification failed..."
        case .classified:
            statusLabel.text = "Classification finished..."
        case .healthy:
            statusLabel.text = "The food is healty!"
            self.healthyImageRecognized()
        case .unhealthy:
            statusLabel.text = "The food in unhealthy!"
            self.unhealthyImageRecognized()
        case .lowConfidence:
            statusLabel.text = "Nothing recognized"
            self.imageNotRecognized()
        case .water:
            statusLabel.text = "Water recognized..."
            self.healthyImageRecognized()
        }
    }
    
    func updateRecognizedObject(recognizedObject : String){
        self.recognizedObject = recognizedObject
    }
    
    func healthyImageRecognized(){
        
        feedbackLabel.text = "Wow, \(recognizedObject)... It sounds great!"
        
        var type : ImageType!
        switch status {
        case .healthy:
            type = ImageType.food
        case .water:
            type = ImageType.water
        default:
            type = ImageType.unknown
        }
        
        do{
            try coreDataAccess!.saveImage(image: inputImage!, status: type, descr: recognizedObject)
        }catch{
            print(error)
        }
        
        // TODO: @Alessio - set timer for notification in 4 hours
        // no notifacitons between 9pm and 8am

        if (type == ImageType.food){
            // food notification
        }else if(type == ImageType.water){
            // water notification
        }
        
        
        // print just for testing
        print(coreDataAccess!.retrieveImages())
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
            
            self.bite1.alpha = 1
            
        }, completion: { (position) in
            
            UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                
                self.bite2.alpha = 1
                self.titleLabel.text = "Yummy!"
                self.statusLabel.text = "I really like this"
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

                                self.dismiss(animated: true, completion: {
                                    self.homeViewController?.updateBars()
                                   if(type == ImageType.water){
                                        self.homeViewController?.updateAnimation(humor: .drinking)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                                self.homeViewController?.updateAnimation(humor: .dancing)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                                                    self.homeViewController?.updateAnimation(humor: .still)
                                                })
                                        })
                                   } else {
                                        self.homeViewController?.updateAnimation(humor: .dancing)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                                            self.homeViewController?.updateAnimation(humor: .still)
                                        })
                                    }
                                })
                            }, completion: nil)
                        })
                    })
                })
            })
        })
    }
    
    func unhealthyImageRecognized(){
        feedbackLabel.text = "You tried to feed me with \(recognizedObject)... Try something different!"
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
            
            self.bite1.alpha = 1
            
        }, completion: { (position) in
            
            
            UIView.animate(withDuration: 0.2, delay: 0.3, options: [], animations: {
                
                self.titleLabel.text = "So bad!"
                self.titleLabel.textColor = UIColor.red
                self.statusLabel.text = "You should try eating something different"
                self.homeViewController?.updateAnimation(humor: .angry)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    self.homeViewController?.updateAnimation(humor: .waiting)
                })
            }, completion: nil)
        })
    }
    
    func imageNotRecognized(){
        feedbackLabel.text = "I just recognize \(recognizedObject)... But I'm not sure if it's right"
        self.titleLabel.text = "Try again!"
        self.statusLabel.text = "Image not recognized or not so clear"
        self.sadFace.alpha = 1
        self.homeViewController?.updateAnimation(humor: .waiting)
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var bite1: UIImageView!
    @IBOutlet weak var bite2: UIImageView!
    @IBOutlet weak var bite3: UIImageView!
    @IBOutlet weak var bite4: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sadFace: UIImageView!
    @IBOutlet weak var feedbackLabel: UILabel!
}

