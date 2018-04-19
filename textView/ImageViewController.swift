
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
    let request = VNDetectTextRectanglesRequest(completionHandler: detectText)
    request.reportCharacterBoxes = true
    self.requests = [request]
    
    let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIImageOrientation.up.rawValue))

    let imageHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: orientation!, options: [:])
    
    do {
      try imageHandler.perform(self.requests)
    } catch {
      print("OH NO")
    }
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
}
