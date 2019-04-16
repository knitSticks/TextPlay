
import UIKit
import Vision

class ImageViewController: UIViewController {
  
  var image: UIImage!
  @IBOutlet weak var predictionLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var faceBoxView: UIView!
  
  var requests = [VNRequest]()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    imageView.image = image
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    findText()
  }
  
  func findText() {
//    let request = findTextRectangles()
//    let rectangleRequest = findRectangles()
    let modelRequest = doTheModelThing()!

//    self.requests = [request]
//    self.requests = [rectangleRequest]
    self.requests = [modelRequest]
    
    let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIImageOrientation.up.rawValue))

    let imageHandler = VNImageRequestHandler(cgImage: image.cgImage!,
                                             orientation: orientation!,
                                             options: [:])
    
    do {
      try imageHandler.perform(self.requests)
    } catch {
      print("OH NO")
    }
  }
    
    func findTextRectangles() -> VNRequest {
        let request = VNDetectTextRectanglesRequest(completionHandler: detectText)
        request.reportCharacterBoxes = true // the default to this is false
        return request
    }
    
    
    func detectText(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            return
        }
        
        let result = observations.map{ $0 as? VNTextObservation }
        
        DispatchQueue.main.async {
            for observation in result {
                print("\(result.count)")
                if let boxes = observation?.characterBoxes {
                    boxes.forEach { self.highlightLetters(box: $0) }
                }
            }
        }
    }
    
    
    
    func highlightLetters(box: VNRectangleObservation) {
        
        let x = box.topLeft.x * imageView.frame.size.width
        let y = (1 - box.topLeft.y) * imageView.frame.size.height
        let w = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
        let h = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: x, y: y, width: w, height: h)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        imageView.layer.addSublayer(outline)
    }
    
    func findRectangles() -> VNRequest {
        let rectangleRequest = VNDetectRectanglesRequest{ request, error in
            guard let observations = request.results else {
                return
            }
            
            let result = observations.map{ $0 as? VNRectangleObservation }
            
            DispatchQueue.main.async {
                for observation in result {
                    print("\(result.count)")
                    if let boxes = observation {
                        self.highlightLetters(box: boxes)
                    }
                }
            }
        }
        rectangleRequest.maximumObservations = 0 //0 - 16
        rectangleRequest.minimumAspectRatio = 0.1
        rectangleRequest.minimumConfidence = 0.2
        rectangleRequest.minimumSize = 0.03 // this seems to be the most important
        return rectangleRequest
    }
    

    
    func doTheModelThing() -> VNCoreMLRequest? {
        var request: VNCoreMLRequest? = nil
        do {
            let model = try VNCoreMLModel(for: GreatModel().model)
            request = VNCoreMLRequest(model: model) { (request, error) in
                guard let observations = request.results as? [VNClassificationObservation] else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.predictionLabel.text = observations.map{ observation in
                        if observation.confidence > 0.3 {
                            return observation.identifier
                        } else {
                            return ""
                        }}.joined(separator: ", ")
                    observations.forEach { thing in
                        print("\((thing.identifier, thing.confidence))")
                    }
                }
            }
        } catch {
            print("Model failed")
        }
        return request
    }
}
