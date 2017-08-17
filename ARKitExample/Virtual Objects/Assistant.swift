//
//  Assistant.swift
//  ARKitExample
//
//  Created by Henry Ho on 8/16/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit


class Assistant: VirtualObject {
    
    var animPlayers = [String: SCNAnimationPlayer]()
    var animKey : String = "idle"
    var targetPos : SCNVector3? = nil
    var lastTime : TimeInterval? = nil
    var lookAtConstraint : SCNLookAtConstraint? = nil
    
    override init() {
        super.init()
    }
    
    override init(modelName: String, fileExtension: String, thumbImageFilename: String, title: String) {
        super.init(modelName: modelName, fileExtension: fileExtension, thumbImageFilename: thumbImageFilename, title: title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadModel() {
        super.loadModel();
        
        // Extract animations
        let url = Bundle.main.url(forResource: modelName, withExtension: fileExtension, subdirectory: "Models.scnassets/\(modelName)")
        let sceneSource = SCNSceneSource.init(url: url as URL!, options: nil)!
        let scene: SCNScene? = sceneSource.scene()

        scene?.rootNode.enumerateChildNodes { (child, _) in
            for key in child.animationKeys {                  // for every animation key
                print("\tAnimationKey found: " + key)
                animPlayers[key] = child.animationPlayer(forKey: key)! // get the animation player
            }
        }
        
        playAnimation("idle");
    }
    
    func playAnimation(_ key : String) {
        // Stop previous animation.
        animPlayers[animKey]?.stop(withBlendOutDuration: 0.25)
        let player: SCNAnimationPlayer? = animPlayers[key]
        if (player != nil) {
            player!.blendFactor = 1
            player!.play()
            animKey = key
            print("\tAnimation triggered: " + key)
        }
    }
    
    func pathToPosition(_ pos : SCNVector3)
    {
        targetPos = pos
    }
    
    func lookAt(_ target: SCNNode) {
        lookAtConstraint = SCNLookAtConstraint(target: target)
        lookAtConstraint?.influenceFactor = 0.5 // Smooth turn.
        lookAtConstraint?.isGimbalLockEnabled = true // This is important, why it is off by default is beyond me.
        lookAtConstraint?.localFront = SCNVector3Make(0, 0, 1)
        self.constraints = [lookAtConstraint!]
    }
    
    func updatePos(_ time : TimeInterval)
    {
        if (lastTime != nil)
        {
            let deltaTime : Float = Float(time - lastTime!)
            if (targetPos != nil) {
                // Increment position by deltaTime * speed
                let dotBefore = self.position.dot(targetPos!)
                let dir = targetPos! - self.position
                
                //self.look(at: targetPos!, up: worldUp, localFront: worldFront)
                //let neoUp = self.worldPosition + SCNVector3Make(0, 10000, 0)
                //lookAtConstraint?.worldUp = neoUp
                
                let speed = (1 ... 10).clamp(dir.length())
                
                self.position += dir * (speed * deltaTime)
                let dotAfter = self.position.dot(targetPos!)
                
                if ((dotBefore >= 0 && dotAfter >= 0) || (dotBefore < 0 && dotAfter < 0)) {
                    // Still going in same direction, so we haven't reached targetPos yet.
                }
                else {
                    // Overshot the targetPos, so set to targetPos
                    self.position = targetPos!
                    targetPos = nil
                }
            }
        }
        lastTime = time
    }
    
    func getZForward(node: SCNNode) -> SCNVector3 {
        return SCNVector3(node.worldTransform.m31, node.worldTransform.m32, node.worldTransform.m33)
    }
}
