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
    
    var tardisbox = TardisBox()
    
    //MARK:- VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        sceneView.delegate = self
        
        sceneView.scene = tardisbox
        
        sceneView.automaticallyUpdatesLighting = false
        
        
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
    
    //MARK:- START NEW SESSION
    func startNewSession(){
        
        self.toast.alpha = 0
        self.toast.frame = self.toast.frame.insetBy(dx: 5, dy: 5)
        
        tardisbox.hide()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    //MARK:- IB ACTIONS
    
    @IBAction func didPan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        // Drag the object on an infinite plane
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlane)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            tardisbox.setTransform(hit.worldTransform)
            
            if recognizer.state == .ended {
                print("ended")
            }
        }
    }
    
    
    @IBAction func didTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        // When tapped on the object, call the object's method to react on it
        let sceneHitTestResult = sceneView.hitTest(location, options: nil)
        if !sceneHitTestResult.isEmpty {
            // We only have one content, so we know which node was hit.
            // If the scene contains multiple objects, you would need to check here if the right node was hit
            tardisbox.reactToTap(in: sceneView)
            return
        }
        
        // When tapped on a plane, reposition the content
        let arHitTestResult = sceneView.hitTest(location, types: .existingPlane)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            tardisbox.setTransform(hit.worldTransform)
            
        }
    }
    
    
}


// : ARSCNViewDelegate removed

extension ViewController {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if tardisbox.isVisible() { return }
        
        // Unhide the content and position it on the detected plane
        if anchor is ARPlaneAnchor {
            tardisbox.setTransform(anchor.transform)
            tardisbox.show()
            tardisbox.reactToInitialPlacement(in: sceneView)
            
            DispatchQueue.main.async {
                self.hideToast()
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        tardisbox.reactToRendering(in: sceneView)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
        tardisbox.reactToDidApplyConstraints(in: sceneView)
    }
}

extension ViewController: ARSessionObserver {
    
    func sessionWasInterrupted(_ session: ARSession) {
        showToast("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        startNewSession()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showToast("Session failed: \(error.localizedDescription)")
        startNewSession()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var message: String? = nil
        
        switch camera.trackingState {
        case .notAvailable:
            message = "Tracking not available"
        case .limited(.initializing):
            message = "Initializing AR session"
        case .limited(.excessiveMotion):
            message = "Too much motion"
        case .limited(.insufficientFeatures):
            message = "Not enough surface details"
        case .normal:
            if !tardisbox.isVisible() {
                message = "Move to find a horizontal surface"
            }
        default:
            // We are only concerned with the tracking states above.
            message = "Camera changed tracking state"
        }
        
        message != nil ? showToast(message!) : hideToast()
    }
}

extension ViewController {
    
    func showToast(_ text: String) {
        label.text = text
        
        guard toast.alpha == 0 else {
            return
        }
        
        toast.layer.masksToBounds = true
        toast.layer.cornerRadius = 7.5
        
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 1
            self.toast.frame = self.toast.frame.insetBy(dx: -5, dy: -5)
        })
        
    }
    
    func hideToast() {
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 0
            self.toast.frame = self.toast.frame.insetBy(dx: 5, dy: 5)
        })
    }
}

