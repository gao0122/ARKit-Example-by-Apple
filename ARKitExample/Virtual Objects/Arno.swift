//
//  Arno.swift
//  ARKitExample
//
//  Created by Henry Ho on 8/16/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

class Arno: Assistant {
    
    override init() {
        super.init(modelName: "arno", fileExtension: "scn", thumbImageFilename: "candle", title: "Arno")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

