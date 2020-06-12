//
//  ProgressView.swift
//  Tamagochi
//
//  Created by Alessio Petrone on 19/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import UIKit

class ProgressView: UIView {

    private var percentgateView: UIView!
    private var animationDuration : Double = 2
    private var currentPercentgate: UInt!
    
    public var isFull: Bool {
        return (currentPercentgate == 100)
    }
       
    public var isEmpty: Bool {
        return (currentPercentgate == 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initProgressBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initProgressBar()
    }
    
    //init progress bar
    private func initProgressBar(){
        // Init currentPercentgate
        currentPercentgate = 0
        
        //set main view
        backgroundColor = .gray
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        
        //set progress view
        percentgateView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(frame.size.height)))
        percentgateView.backgroundColor = .blue
        percentgateView.layer.cornerRadius = 10
        percentgateView.layer.masksToBounds = true
    
        addSubview(percentgateView)
    }
    
    /**
     Sets the progress level from a percentage, animated.
     Accept values from 0 to 100. Values bigger than 100 will be considered like 100
        - Parameter to : The  percentage that needs to be displayed as a progress bar.
     */
    public func setProgressBar(to percentage: UInt){
        
        var valuecurrentPercentgate = percentage
        
        if (percentage > 100){
            valuecurrentPercentgate = 100
        }
        
        self.currentPercentgate = valuecurrentPercentgate
        
        let width = (frame.size.width * CGFloat(valuecurrentPercentgate))/100
        
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            self.percentgateView.frame.size.width = width
            
        }, completion: nil)
    }
    
    /**
     Set background color of progress bar
     - Parameter color : Background color of progress bar
     */
    public func setBackgroundColor(color: UIColor){
        backgroundColor = color
    }
    
    /**
     Set color of progress bar
     - Parameter color : Progress color
     */
    public func setProgressColor(color: UIColor){
        percentgateView.backgroundColor = color
    }
    
    /**
     Get current  percentgate value
     - Returns: Value of current percentgate
     */
    public func getCurrentcurrentPercentgate() -> UInt{
        return currentPercentgate
    }

}
