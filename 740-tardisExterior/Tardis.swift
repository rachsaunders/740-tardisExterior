//
//  Tardis.swift
//  740-tardisExterior
//
//  Created by Rachel Saunders on 01/11/2020.
//


import Foundation
import SceneKit
import ARKit

class Tardis: SCNScene {
    
    // Special nodes used to control animations of the model
    private let contentRootNode = SCNNode()
    private var geometryRoot: SCNNode!
    private var jaw: SCNNode!
    private var skin: SCNMaterial!
    
    // Animations
    private var idleAnimation: SCNAnimation?
    
    // State variables
    private var modelLoaded: Bool = false
    
    private let focusNodeBasePosition = simd_float3(0, 0.1, 0.25)
    private var lastRelativePosition: RelativeCameraPositionToHead = .tooHighOrLow
    
  
    
    // Enums to describe the current state
    private enum RelativeCameraPositionToHead {
        case withinFieldOfView(Distance)
        case tooHighOrLow
        
        var rawValue: Int {
            switch self {
            case .withinFieldOfView(_) : return 0
            case .tooHighOrLow : return 3
            }
        }
    }
    
    private enum Distance {
        case outsideTargetLockDistance
    }
    
    private enum TardisAnimationState {
        case tardisboxClosed
        case tardisboxOpened

    }
    
    // MARK: - Initialization and Loading
    
    override init() {
        super.init()
        
        // Load the environment map
   //     self.lightingEnvironment.contents = UIImage(named: "")!

        loadModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "tardisbox", inDirectory: "art.scnassets") else {
            return
        }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        self.rootNode.addChildNode(contentRootNode)
        contentRootNode.addChildNode(wrapperNode)
       
        modelLoaded = true
    }
    
}
