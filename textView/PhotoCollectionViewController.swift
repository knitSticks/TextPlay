
import UIKit

class PhotoCollectionViewController: UICollectionViewController {
  
  var photos: [UIImage] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  @IBAction func addTapped(_ sender: Any) {
    let controller = UIImagePickerController()
    controller.delegate = self
    controller.sourceType = .camera
    
    present(controller, animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "imageDetail" else { return }
    let cell = sender as! PictureCollectionViewCell
    let indexPath = collectionView!.indexPath(for: cell)!
    let image = photos[indexPath.row]
    let imageController = segue.destination as! ImageViewController
    imageController.image = image
  }
}

extension PhotoCollectionViewController
{
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PictureCollectionViewCell
    cell.imageView.image = photos[indexPath.row]
    
    return cell
  }
}

extension PhotoCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      photos.append(image)
      collectionView?.reloadData()
    }
  }
}

