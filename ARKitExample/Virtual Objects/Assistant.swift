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
                print(key)
                animPlayers[key] = child.animationPlayer(forKey: key)! // get the animation player
            }
        }
        
        animPlayers["backflip"]?.play()
    }
}
