//
//  DemoScene.swift
//  SceneKit Shapes
//
//  Created by Hal Mueller on 11/29/15.
//  Copyright © 2015 Hal Mueller. All rights reserved.
//

import SceneKit

#if os(iOS) || os(tvOS)
	private typealias MyColor = UIColor
	private typealias MyFont = UIFont
#elseif os(OSX)
	private typealias MyColor = NSColor
	private typealias MyFont = NSFont
#endif

class DemoScene: SCNScene {
	let materials: [SCNMaterial]
	let followSpotNode: SCNNode
	let overheadCameraNode: SCNNode
	let fixedCameraNode: SCNNode
	
	override init() {
		let objectSize = CGFloat(0.5)
		let carouselRadius = 5 * objectSize
		let cameraFOVDegrees = 60.0
		
		let colors = [MyColor.cyanColor(), MyColor.magentaColor(), MyColor.yellowColor(), MyColor.redColor(), MyColor.blueColor(), MyColor.greenColor()]
		var newMaterials: [SCNMaterial] = []
		for color in colors {
			let thisMaterial = SCNMaterial()
			thisMaterial.diffuse.contents = color
			thisMaterial.specular.contents = MyColor.whiteColor()
			newMaterials.append(thisMaterial)
		}
		materials = newMaterials
	
		let sharedCamShape = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
		
		let overheadCamera = SCNCamera()
		overheadCamera.xFov = cameraFOVDegrees
		overheadCamera.yFov = cameraFOVDegrees
		print(overheadCamera.xFov, overheadCamera.yFov)
		overheadCameraNode = SCNNode(geometry: sharedCamShape)
		overheadCameraNode.camera = overheadCamera
		//fixedCameraNode.position = SCNVector3Make(-1 * carouselRadius, carouselRadius, carouselRadius)
		overheadCameraNode.position = SCNVector3Make(0, 3 * carouselRadius, 0)
		
		let fixedCamera = SCNCamera()
		fixedCamera.xFov = cameraFOVDegrees
		fixedCamera.yFov = cameraFOVDegrees
		print(fixedCamera.xFov, fixedCamera.yFov)
		fixedCameraNode = SCNNode(geometry: sharedCamShape)
		fixedCameraNode.camera = fixedCamera
		fixedCameraNode.position = SCNVector3Make(-1 * carouselRadius, carouselRadius, carouselRadius)
		//fixedCameraNode.position = SCNVector3Make(0, 3 * carouselRadius, 0)
		
		let followCamera = SCNCamera()
		followCamera.xFov = 30
		followCamera.yFov = 30
//		followCamera.focalBlurRadius = 3.0
		let followSpotLight = SCNLight()
		followSpotLight.type = SCNLightTypeSpot
		followSpotLight.castsShadow = true
		followSpotNode = SCNNode(geometry: sharedCamShape)
		followSpotNode.camera = followCamera
		followSpotNode.light = followSpotLight
		followSpotNode.position = SCNVector3Make(carouselRadius, carouselRadius/2, carouselRadius)
		
		super.init()
		
		let ambientLight = SCNLight()
		ambientLight.type = SCNLightTypeAmbient
		let ambientLightNode = SCNNode()
		ambientLightNode.light = ambientLight
		self.rootNode.addChildNode(ambientLightNode)

		self.rootNode.addChildNode(followSpotNode)
		self.rootNode.addChildNode(overheadCameraNode)
		self.rootNode.addChildNode(fixedCameraNode)
		
		let carousel = SCNNode()
		carousel.position = SCNVector3Make(0, objectSize, 0)
		let rotate = SCNAction.repeatActionForever(SCNAction.rotateByX(0.0, y: CGFloat(M_PI), z: 0, duration: 20.0))
		carousel.runAction(rotate)
		self.rootNode.addChildNode(carousel)

		overheadCameraNode.constraints = [SCNLookAtConstraint(target: carousel)]
		fixedCameraNode.constraints = [SCNLookAtConstraint(target: carousel)]
		
		let centerString = NSAttributedString(string: "center", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
		 NSFontAttributeName: MyFont(name: "Helvetica", size: 0.5)!])
		let centerText = SCNText(string: centerString, extrusionDepth: objectSize/10)
		centerText.materials = materials
		let centerNode = SCNNode(geometry: centerText)
		centerNode.constraints = [SCNBillboardConstraint()]
		self.rootNode.addChildNode(centerNode)

		let chamferedBox = SCNBox(width: objectSize, height: objectSize, length: objectSize/2, chamferRadius: 0.2)
		
		let box = SCNBox(width: objectSize/2, height: objectSize, length: objectSize, chamferRadius: 0)
		
		let capsule = SCNCapsule(capRadius: objectSize/4, height: objectSize)
	
		let standardSphere = SCNSphere(radius: objectSize/2)
		standardSphere.geodesic = false
		
		let tube = SCNTube(innerRadius: 0.4 * objectSize, outerRadius: 0.5 * objectSize, height: objectSize)
		
		let geodesicSphere = SCNSphere(radius: objectSize/2)
		geodesicSphere.geodesic = true
		
		let pyramid = SCNPyramid(width: objectSize/3, height: objectSize/5, length: objectSize)
		
		let plane = SCNPlane(width: objectSize, height: objectSize)
		
		let cone1 = SCNCone(topRadius: 0, bottomRadius: objectSize/4, height: objectSize)

		let cone2 = SCNCone(topRadius: objectSize/6, bottomRadius: objectSize/3, height: objectSize)
		
		let sourceString = NSAttributedString(string: "hello", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
		 NSFontAttributeName: MyFont(name: "Chalkduster", size: 0.5)!])
		let text = SCNText(string: sourceString, extrusionDepth: objectSize/10)
		
		let torus = SCNTorus(ringRadius: objectSize, pipeRadius: objectSize/8)

		let geometries = [chamferedBox, box, capsule, standardSphere, tube, geodesicSphere, pyramid, text, plane, cone1, cone2, torus]
		var index = 0
		let angleIncrement = 2.0 * M_PI/Double(geometries.count)
		var lastNode: SCNNode!
		for geometry in geometries {
			geometry.materials = materials
			let node = SCNNode(geometry: geometry)
			let angle = CGFloat(angleIncrement * Double(index++))
			let x = carouselRadius * cos(angle)
			let y = carouselRadius * sin(angle)
			node.position = SCNVector3Make(x, 0, y)
			carousel.addChildNode(node)
			lastNode = node
		}
		
		followSpotNode.constraints = [SCNLookAtConstraint(target: lastNode)]
		
		let floor = SCNFloor()
		self.rootNode.addChildNode(SCNNode(geometry: floor))
		
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

}