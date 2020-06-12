//
//  UILoggingViewController.swift
//  VCLifeCycle - based on Stanford University CS193p Instructor (Paul Hegarty)
//
//  Created by Wallace Ugulino on 17/11/19 to be used in classroom.
//

import Foundation
import UIKit

class UILoggingViewController: UIViewController {

	private struct LogGlobals {
		var prefix = ""
		var instanceCounts = [String: Int]()
		var lastLogTime = Date()
		var indentationInterval: TimeInterval = 1
		var indentationString = "__"
	}
    
    public static var logging = true
	
	private static var logGlobals = LogGlobals()
	
	private var instanceCount: Int!
	
	private static func logPrefix(for loggingName: String)-> String{
		if logGlobals.lastLogTime.timeIntervalSinceNow < -logGlobals.indentationInterval {
			logGlobals.prefix += logGlobals.indentationString
			print("")
		}
		logGlobals.lastLogTime = Date()
		return logGlobals.prefix + loggingName
	}
	
	private static func bumpInstanceCount(for loggingName: String) -> Int {
		logGlobals.instanceCounts[loggingName] = (logGlobals.instanceCounts[loggingName] ?? 0 ) + 1
		return logGlobals.instanceCounts[loggingName]!
	}
	
	var vclLoggingName: String {
		return String(describing: type(of: self))
	}
	
	private func logVCL(_ msg: String){
        if UILoggingViewController.logging {
                if instanceCount == nil {
                    instanceCount = UILoggingViewController.bumpInstanceCount(for: vclLoggingName)
                }
                print("\(UILoggingViewController.logPrefix(for: vclLoggingName))(\(instanceCount!)): \(msg)")
        }
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		logVCL("init(coder:) - created via InterfaceBuilder")
	}
	
	deinit{
		logVCL("left the heap")
	}
	
	override func awakeFromNib() {
		logVCL("awakeFromNib()")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		logVCL("viewDidLoad()")
		// Do any additional setup after loading the view.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		logVCL("viewWillAppear(animated = \(animated))")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		logVCL("viewDidAppear(animated = \(animated))")
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		logVCL("viewWillDisappear(animated = \(animated))")
 	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		logVCL("viewDidDisappear(animated = \(animated))")
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		logVCL("viewWillLayoutSubviews() bounds.size = \(view.bounds.size)")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		logVCL("viewDidLayoutSubviews() bounds.size = \(view.bounds.size)")
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		logVCL("viewWillTransition(to size=\(size), with: coordinator)")
		coordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext)->Void in
			self.logVCL("begin animate(alongsideTransition:completion:)")
		}, completion: {context -> Void in
			self.logVCL("end animate(alongsideTransition:completion:)")})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		logVCL("didReceiveMemoryWarning()")
	}
}


