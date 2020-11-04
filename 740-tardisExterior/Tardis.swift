//
//  TardisBox.swift
//  740-tardisExterior
//
//  Created by Rachel Saunders on 01/11/2020.
//


import Foundation
import SceneKit
import ARKit

class TardisBox: SCNScene {
    
    // Special nodes used to control animations of the model
    private let contentRootNode = SCNNode()
    private var geometryRoot: SCNNode!
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
    
    private enum TardisBoxAnimationState {
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
    
    // MARK: - Public API
    
    func show() {
        contentRootNode.isHidden = false
    }
    
    func hide() {
        contentRootNode.isHidden = true
    }
    
    func isVisible() -> Bool {
        return !contentRootNode.isHidden
    }
    
    func setTransform(_ transform: simd_float4x4) {
        contentRootNode.simdTransform = transform
    }
}



// MARK: - React To Placement and Tap

extension TardisBox {
    
    func reactToPositionChange(in view: ARSCNView) {
        self.reactToPlacement(in: view)
    }
    
    func reactToInitialPlacement(in view: ARSCNView) {
        self.reactToPlacement(in: view, isInitial: true)
    }
    
    private func reactToPlacement(in sceneView: ARSCNView, isInitial: Bool = false) {
        if isInitial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.getColorFromEnvironment(sceneView: sceneView)
                self.activateCamouflage(true)
            })
        } else {
            DispatchQueue.main.async {
                self.updateCamouflage(sceneView: sceneView)
            }
        }
    }
    
    func reactToTap(in sceneView: ARSCNView) {
        self.activateCamouflage(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.activateCamouflage(true)
        })
    }
    
    private func activateCamouflage(_ activate: Bool) {
        
   
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
     
        SCNTransaction.commit()
    }
    
    private func updateCamouflage(sceneView: ARSCNView) {
        getColorFromEnvironment(sceneView: sceneView)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.5
        SCNTransaction.commit()
    }
    
    private func getColorFromEnvironment(sceneView: ARSCNView) {
        _ = sceneView.projectPoint(contentRootNode.worldPosition)
        
        
    }
}

// MARK: - React To Rendering

extension TardisBox {
    
    func reactToRendering(in sceneView: ARSCNView) {
        // Update environment map to match ambient light level
        lightingEnvironment.intensity = (sceneView.session.currentFrame?.lightEstimate?.ambientIntensity ?? 1000) / 100
        
    
    
    
}
}
    
// MARK: - React To DidApplyConstraints

extension TardisBox {
    
    func reactToDidApplyConstraints(in sceneView: ARSCNView) {
        guard modelLoaded, let pointOfView = sceneView.pointOfView else {
            return
        }
        
        // Correct the user position such that it is a few centimeters in front of the camera.
        let translationLocal = SCNVector3(0, 0, -0.012)
        let translationWorld = pointOfView.convertVector(translationLocal, to: nil)
        let camTransform = SCNMatrix4Translate(pointOfView.transform, translationWorld.x, translationWorld.y, translationWorld.z)
        let userPosition = simd_float3(camTransform.m41, camTransform.m42, camTransform.m43)
        
        
    }
    
    
}

// MARK: - Helper functions

extension TardisBox {
    
    private func rad(_ deg: Float) -> Float {
        return deg * Float.pi / 180
    }
    
    private func randomlyUpdate(_ vector: inout simd_float3) {
        switch arc4random() % 400 {
        case 0: vector.x = 0.1
        case 1: vector.x = -0.1
        case 2: vector.y = 0.1
        case 3: vector.y = -0.1
        case 4, 5, 6, 7: vector = simd_float3()
        default: break
        }
    }
    
    private func setupSpecialNodes() {
        // Retrieve nodes we need to reference for animations.
        geometryRoot = self.rootNode.childNode(withName: "TardisBox", recursively: true)
        
        skin = geometryRoot.geometry?.materials.first
        
        // Fix materials
        geometryRoot.geometry?.firstMaterial?.lightingModel = .physicallyBased
        geometryRoot.geometry?.firstMaterial?.roughness.contents = "art.scnassets/textures/tardisBox_ROUGHNESS.png"
        let shadowPlane = self.rootNode.childNode(withName: "Shadow", recursively: true)
        shadowPlane?.castsShadow = false
        
    }
    
    private func setupConstraints() {
        // not needed
    }
    
    private func resetState() {
        // not needed
    }
    
    private func setupShader() {
        guard let path = Bundle.main.path(forResource: "skin", ofType: "shaderModifier", inDirectory: "art.scnassets"),
              let shader = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            return
        }
        
        skin.shaderModifiers = [SCNShaderModifierEntryPoint.surface: shader]
        
        skin.setValue(Double(0), forKey: "blendFactor")
        skin.setValue(NSValue(scnVector3: SCNVector3Zero), forKey: "skinColorFromEnvironment")
        
        let sparseTexture = SCNMaterialProperty(contents: UIImage(named: "art.scnassets/textures/tardisBox_DIFFUSE_BASE.png")!)
        skin.setValue(sparseTexture, forKey: "sparseTexture")
    }
}


