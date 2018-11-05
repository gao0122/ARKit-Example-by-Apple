/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The virtual cup.
*/

import Foundation

class Cup: VirtualObject {
	
	override init() {
		super.init(modelName: "cup", fileExtension: "scn", thumbImageFilename: "cup", title: "Cup")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
