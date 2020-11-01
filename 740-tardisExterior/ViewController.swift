//
//  ViewController.swift
//  740-tardisExterior
//
//  Created by Rachel Saunders on 31/10/2020.
//
// This app is made as part of a module for my Masters Degree. All programming is done by Rachel Saunders using 3D assets by Tom Saunders with permission.

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    //MARK:- OUTLETS
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var toast: UIVisualEffectView!
    
    //MARK:- VARS
    
    var tardisbox = Tardis()
    
    //MARK:- VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        sceneView.delegate = self
        
        sceneView.scene = tardisbox
        
        
    }
    
    //MARK:- VIEWDIDAPPEAR
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("Sorry! But your phone cannot go into time and space!")
        }
        
        UIApplication.shared.isIdleTimerDisabled = true

        startNewSession()
    }
    
    //MARK:- VIEWWILLDISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func startNewSession(){
        
        self.toast.alpha = 0
        self.toast.frame = self.toast.frame.insetBy(dx: 5, dy: 5)
        
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    //    MARK:- CAMERA TRACKING STATES
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        // SWITCH CASE TO DO ABOUT MESSAGES TOAST WILL SAY
        var message: String? = nil
        
        switch camera.trackingState {
        case .notAvailable:
            message = "tracking not available"
        case .limited(.initializing):
            message = "Initialising AR..."
        case .limited(.excessiveMotion):
            message = "Stop moving!"
        case .limited(.insufficientFeatures):
            message = "Not enough surface details"
        case .normal:
            // To do
            print("you need to complete this Rach!")
        default:
            message = "Camera changed tracking state"
            
        }
        
        message != nil ? showToast(message!) : hideToast()
    }
}

//MARK:- TOAST SETTINGS

extension ViewController {
    
    func showToast(_ text: String) {
        label.text = text
        
        guard toast.alpha == 0 else {
            return
        }
    }
    
    func hideToast() {
        UIView.animate(withDuration: 0.25) {
            self.toast.alpha = 0
        }

    }
    
}
