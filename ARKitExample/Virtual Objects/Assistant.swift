//
//  Assistant.swift
//  ARKitExample
//
//  Created by Henry Ho on 8/16/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


class Assistant: VirtualObject {
    
    var animations = [String: CAAnimation]()
    var animKey : String = "idle"
    
    var targetPos : SCNVector3? = nil
    var lookAtConstraint : SCNLookAtConstraint? = nil
    var session : ARSession? = nil
    let lookAtNode : SCNNode = SCNNode() // SCNNode(geometry:SCNSphere(radius: 0.1))
    
    // collidable target
    var collidable : SCNNode? = nil
    var collidableScene : SCNScene? = nil
    
    // time
    var lastTime : TimeInterval? = nil
    var currTime : TimeInterval? = nil
    var deltaTime : Float? = nil
    
    
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
                let animation = child.animation(forKey: key)! // get the animation
                animation.usesSceneTimeBase = false           // make it system time based
                animation.repeatCount = Float.infinity        // make it repeat forever
                child.removeAnimation(forKey: key)
                animations[key] = animation;
            }
        }
        
        self.addAnimation(animations["idle"]!, forKey: "idle")
    }
    
    func playAnimation(_ key : String) {
        //if (self.animations.count > 0)
        self.addAnimation(animations[key]!, forKey: key)
        print("starting animation " + key + ", animKeysCnt=" + String(self.animationKeys.count))
    }
    
    func stopAnimation(_ key : String) {
        self.removeAnimation(forKey: key, blendOutDuration: 0.3)
        print("stopping animation " + key + ", animKeysCnt=" + String(self.animationKeys.count))
    }
    
    func moveToCollidable(_ target: SCNNode,_ scene: SCNScene) {
        collidable = target
        collidableScene = scene
        // Determine where to go. We want to end up right next to the object (at the same Y-value),
        // so create a segment between assistant and target, but at the target's Y-value.
        let p0 = SCNVector3Make(self.worldPosition.x, collidable!.worldPosition.y, self.worldPosition.z)
        let p1 = collidable!.worldPosition

        
        let results = scene.physicsWorld.rayTestWithSegment(from: p0, to: p1, options:[.collisionBitMask: 1,.searchMode: SCNPhysicsWorld.TestSearchMode.closest])
        
        if let result = results.first {
            self.moveToPosition(result.worldCoordinates)
            collidable = nil
        }
        else {
            print("Couldn't find collision path to target")
        }
        
        // Face the target and do moving animation
        self.lookAt(target)
        self.playAnimation("forward")
    }
    
    func moveToPosition(_ pos : SCNVector3) {
        targetPos = pos
    }
    
    func lookAt(_ target: SCNNode, _ influenceFactor : Float = 0.5) {
        lookAtConstraint = SCNLookAtConstraint(target: target)
        lookAtConstraint?.influenceFactor = 0.5 // Smooth turn.
        lookAtConstraint?.isGimbalLockEnabled = true // This is important, why it is off by default is beyond me.
        lookAtConstraint?.localFront = SCNVector3Make(0, 0, 1)
        self.constraints = [lookAtConstraint!]
    }
    
    func lookAtCamera(){
        
        guard let cameraTransform = session?.currentFrame?.camera.transform else {
            print("No cameraTransform")
            return
        }
        
        lookAtNode.worldPosition = SCNVector3.positionFromTransform(cameraTransform)
        print("camera worldPosition = " + lookAtNode.worldPosition.friendlyString())
        self.lookAt(lookAtNode, 0.05)
    }
    
    func update(_ time : TimeInterval, _ session : ARSession)
    {
        currTime = time
        self.session = session
        
        if (lastTime != nil)
        {
            deltaTime = Float(time - lastTime!)
            self.updateMoveTarget()
            self.updateMove()
        }
        lastTime = time
    }
    
    func updateMove()
    {
        if (targetPos != nil) {
            // Increment position by deltaTime * speed
            let dir = targetPos! - self.position
            
            let lengthSqrd = dir.lengthSqrd()
            let speed = (1.0 ... 10.0).clamp(lengthSqrd / 1.0)
            
            self.position += dir.normalized() * (speed * deltaTime!)
            let dirAfter = targetPos! - self.position
            
            //print("speed:" + String(speed) )
            // Check to see if we went past the targetPos.
            if (dir.dot(dirAfter) <= 0 ) {
                // Overshot the targetPos, so set to targetPos
                self.position = targetPos!
                targetPos = nil
                self.stopAnimation("forward")
                //print ("targetPos reached")
                self.lookAtCamera()
            }
        }
    }
    
    func updateMoveTarget()
    {
        if (collidable != nil) {
            self.moveToCollidable(collidable!, collidableScene!)
        }
    }
    
    func getZForward(node: SCNNode) -> SCNVector3 {
        return SCNVector3(node.worldTransform.m31, node.worldTransform.m32, node.worldTransform.m33)
    }
}
