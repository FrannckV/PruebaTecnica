//
//  ViewController.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 07/03/22.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var photoButton: UIButton!
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    private var nombre: String = ""
    
    var graficaManager = GraficaManager()
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graficaManager.delegate = self
        
        graficaManager.fetchGrafica()
        
        view.backgroundColor = UIColor(hex: getColor(color: K.colorBlueChild))
    }
    
    @IBAction func didPhotoButtonPressed(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        photoButton.setImage(resizeImage(image: image!, targetSize: CGSize(width: 90, height: 90))
                             , for: .normal)
        picker.dismiss(animated: true, completion: nil)
        
    }
    func uploadImage() {
        storage.child("images/\(nombre).png").putData((image?.pngData())!, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            self.storage.child("images/\(self.nameTextField.text!).png").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: K.urlKey)
            })
        })
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func addNewEntry() {
        let object: [String: String] = [
            "name" : nombre
        ]
        database.child(K.databaseChild).setValue(object)
    }
    func getColor(color: String) -> String {
        var themeColor = ""
        database.child(color).getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            themeColor = snapshot.value as! String
        });
        return themeColor
    }
}
// MARK: - GraficaManagerDelegate
extension ViewController: GraficaManagerDelegate {
    func didUpdateGraficas(_ graficasManager: GraficaManager, grafica: GraficaModel) {
        DispatchQueue.main.async {
            // Acomodar las cosas en la gráfica
            print("--------------- SUCCESS --------------------")
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

// MARK: - UITextFieldController
extension ViewController: UITextViewDelegate {
    
    @IBAction func guardarPressed(_ sender: UIButton) {
        nameTextField.endEditing(true)
        nombre = nameTextField.text!
        addNewEntry()
        uploadImage()
        nameTextField.text = ""
        photoButton.setImage(UIImage(named: "paintbrush.fill"), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
        return true
    }
   
    private func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Nombre"
            return false
        }
    }
    private func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let name = nameTextField.text {
            nombre = name
        }
        
        nameTextField.text = ""
    }
   
}
// MARK: - UIColor
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
