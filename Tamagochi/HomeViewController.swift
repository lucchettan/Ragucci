//
//  HomeViewController.swift
//  Tamagochi
//
//  Created by Benjamin Burkhardt on 11/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//
import UIKit
import CoreData
import SceneKit


/*
 This represents the main scene. The Tamagotchi is shown here.
 The user should be triggered to take a picture.
 */
class HomeViewController: UILoggingViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController!
    
    // Connection to the Outlet in the Storyboard
    @IBOutlet weak var thirstBar: UIView!
    @IBOutlet weak var hungerBar: UIView!
    @IBOutlet weak var barBackgroundView: UIView!
    @IBOutlet weak var journeyIcon: UIButton!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var feedMeButton: UIButton!
    @IBOutlet weak var daysRemaningAnimation: UIImageView!
    @IBOutlet weak var daysRemaining: UILabel!
    @IBOutlet weak var tamagotchiView: SCNView!
    
    // CoreData
    var container: NSPersistentContainer!
    let persistentDataManager =  PersistentDataManager()
    
    //    animations var
        var myScene = SCNScene()
        var cameraNode = SCNNode()
        var idle:Bool = true
        enum humor {
            case still, eating, drinking, waiting, dancing, angry
        }
    //    value to switch to change the animation

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initializations of colors and fonts
        initializeOutlets()
        
        // CoreData setup
        container = NSPersistentContainer(name: "DataModel")
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        // start animation for challenge times
        updateAnimation()
        runContinuously()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update data
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController){
        // we have to update the bars after the image was scanned
        updateBars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // update outlets
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            
            // Check if it's the first launch of the app to show the Tutorial
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            if launchedBefore  {
                print("Not first launch.")
            } else {
                print("First launch, setting UserDefault.")
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                self.performSegue(withIdentifier: "tutorial", sender: nil)
            }
        }
        
        // Updating hunger and thirst bars
        updateBars()
        tamagotchiView.layer.cornerRadius = tamagotchiView.frame.size.width/2.0
        tamagotchiView.shadowOffset = CGSize(width: 5, height: 5)
    }
    
    
    @IBAction func scanButton(_ sender: UIButton) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        // catch expection in Simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        else {
            imagePicker.sourceType = .savedPhotosAlbum // or .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("Image captured!")
        let inputImage = info[.originalImage] as! UIImage
        goToFeedbackViewController(inputImage: inputImage)
    }
    
    func goToFeedbackViewController(inputImage: UIImage){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let feedbackViewController = storyBoard.instantiateViewController(withIdentifier: "feedbackViewController") as! FeedbackViewController
        feedbackViewController.inputImage = inputImage
        feedbackViewController.coreDataAccess = persistentDataManager
        feedbackViewController.homeViewController = self
        self.present(feedbackViewController, animated: true, completion: nil)
    }
    
    @IBAction func goToHistoryViewController(_ sender: UIButton) {
        goToHistoryViewController()
    }
    func goToHistoryViewController(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let historyViewController = storyBoard.instantiateViewController(withIdentifier: "historyViewController") as! LatestPhotosViewController
        historyViewController.persistentDataManager = persistentDataManager
        self.present(historyViewController, animated: true, completion: nil)
        
        
    }

    
    /// MARK - Prepare stuff for the next ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? FeedbackViewController {
            nextVC.container = container
        }
    }
    
    
    // This is the initizialization of the colors and the fonts of changeble outlets
    // in the Storyboard
    
    func initializeOutlets () {
        settingsIcon.titleLabel?.font = UIFont(name: "SFProText-Light", size: 35)
        journeyIcon.titleLabel?.font = UIFont(name: "SFProText-Light", size: 35)
        
        settingsIcon.setTitleColor(GlobalSettings.colors[6], for: .normal)
        journeyIcon.setTitleColor(GlobalSettings.colors[6], for: .normal)
        
        thirstBar.backgroundColor = GlobalSettings.colors[1]
        hungerBar.backgroundColor = GlobalSettings.colors[3]
        
        view.backgroundColor = GlobalSettings.colors[0]
        feedMeButton.backgroundColor = GlobalSettings.colors[4]
    }
    
    @objc func runContinuously(){
        UIView.animate(withDuration: 5.0, animations: {
        self.daysRemaningAnimation.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        })
        Timer.scheduledTimer(withTimeInterval: 5.1, repeats: false) { (timer) in
            self.daysRemaningAnimation.transform = CGAffineTransform(rotationAngle: 0)
            self.updateBars()
            self.runContinuously()
        }
    }
    
    // Function to update the bars width depending on hunger and thirst of the Tamagotchi
    func updateBars () {
        
        var healthStatus = self.persistentDataManager.readHealthStatus()
        
        if healthStatus.count == 0 {
            self.persistentDataManager.initHealthStatus()
            healthStatus = self.persistentDataManager.readHealthStatus()
        }
        
        // thirsty level
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let barWidth: CGFloat = self.barBackgroundView.frame.width/100 * CGFloat(healthStatus["thirsty"]!)
            self.thirstBar.frame = CGRect(x: self.thirstBar.frame.minX, y: self.thirstBar.frame.minY, width: barWidth, height: self.thirstBar.frame.height)
        })
        
        // hungry level
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let barWidth: CGFloat = self.barBackgroundView.frame.width/100 * CGFloat(healthStatus["hungry"]!)
            self.hungerBar.frame = CGRect(x: self.hungerBar.frame.minX, y: self.hungerBar.frame.minY, width: barWidth, height: self.hungerBar.frame.height)
        })
        
        // update challenge counter
        daysRemaining.text = String(healthStatus["daysInChallenge"]!)

        
    }
    
    override func didReceiveMemoryWarning() {
        // release stuff, otherwise it gets killed
        print("Memory warning!!!")
    }
    
    
    func animateWith (animation: String) {
        // Load the character in the idle animation
        let newScene = SCNScene()
        tamagotchiView.scene = newScene
        let idleScene = SCNScene(named: animation)!
        // Contains the hole animation
        let node = SCNNode()
        // Add all animation nodes to a parent xnode
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        // Set up properties
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.2, 0.2, 1)
        // Add the animations node to the scene
        tamagotchiView.backgroundColor = .orange
        tamagotchiView.scene?.rootNode.addChildNode(node)
        // Load all the DAE animations
    }
    
    func updateAnimation(humor: humor? = nil){
        // switch animation for challenge times
        switch humor {
            case .still:
                animateWith(animation: "art.scnassets/goast/idleFixed.dae")
            case .eating:
                animateWith(animation: "art.scnassets/goast/eatingFixed.dae")
            case .drinking:
                animateWith(animation: "art.scnassets/goast/drinkingFixed.dae")
            case .waiting:
                animateWith(animation: "art.scnassets/goast/angryFixed.dae")
            case .dancing:
                animateWith(animation: "art.scnassets/goast/dancingFixed.dae")
            case .angry:
                animateWith(animation: "art.scnassets/goast/kickFixed.dae")
            default:
                animateWith(animation: "art.scnassets/goast/idleFixed.dae")
        }
    }
}
