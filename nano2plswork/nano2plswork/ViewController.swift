import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var parameterNode: SCNNode!
    var moistPercentNode: SCNNode!
    var lightPercentNode: SCNNode!
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        if let scene = SCNScene(named: "art.scnassets/parameter.scn") {
            print("Scene loaded successfully")
            lightPercentNode = scene.rootNode.childNode(withName: "lightPar", recursively: true)
            moistPercentNode = scene.rootNode.childNode(withName: "moistPar", recursively: true)
            parameterNode = scene.rootNode.childNode(withName: "parameterNode", recursively: true)
            if parameterNode != nil {
                print("parameterNode loaded successfully")
                parameterNode.eulerAngles.x = .pi / 2
                parameterNode.removeFromParentNode()
            } else {
                print("Failed to find parameterNode in the scene")
            }
        } else {
            print("Failed to load the parameter scene")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "test1", bundle: Bundle.main) {
            print("Tracking images loaded successfully")
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 1
        } else {
            print("Failed to load tracking images: ARReferenceImage.referenceImages returned nil")
        }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            print("Image anchor detected: \(imageAnchor.referenceImage.name ?? "Unknown")")
        
            if let shapeNode = parameterNode {
                node.addChildNode(shapeNode)
            }
            
            // Simulated values for light and moisture parameters
            let lightValue = 100.0 // Example light value
            let moistValue = 2.0 // Example moisture value
            
            // Update height of lightPercentNode based on lightValue
            updateNodeHeight(lightPercentNode, value: lightValue)
            
            // Update height of moistPercentNode based on moistValue
            updateNodeHeight(moistPercentNode, value: moistValue)
            
            // Update color of lightPercentNode based on lightValue
            updateNodeColor(lightPercentNode, value: lightValue)
            
            // Update color of moistPercentNode based on moistValue
            updateNodeColor(moistPercentNode, value: moistValue)
        }
        
        return node
    }
    
    func updateNodeColor(_ node: SCNNode, value: Double) {
        let color: UIColor
        if value < 30.0 {
            color = .red
        } else if value > 60.0 {
            color = .green
        } else {
            color = .yellow
        }
        
        if let geometry = node.geometry {
            for material in geometry.materials {
                material.diffuse.contents = color
            }
        }
    }
    
    func updateNodeHeight(_ node: SCNNode, value: Double) {
        // Define the maximum height for the node (corresponding to 100%)
        let maxHeight: Float = 1.0 // Change this according to your original height
        
        // Calculate the new height based on the percentage value
        let newHeight = maxHeight * Float(value / 100.0)
        
        // Set the scale of the node to adjust its height along the z-axis
        node.scale.z = newHeight / maxHeight
        node.position.z -= (node.boundingBox.max.z - node.boundingBox.min.z) * (node.scale.z - 1) / 2.0
    }
    
  
    @IBOutlet weak var LightPromt: UILabel!
    
    @IBOutlet weak var MoistPromt: UILabel!
    
    @IBOutlet weak var lightTF: UITextField!
    @IBOutlet weak var moistTF: UITextField!
    
    @IBAction func lightSubmit(_ sender: UIButton) {
    }
    @IBAction func moistSubmit(_ sender: UIButton) {
    }
    
}
