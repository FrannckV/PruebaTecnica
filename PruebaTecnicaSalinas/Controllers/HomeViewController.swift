//
//  HomeViewController.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 08/03/22.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import SwiftUI


class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - PROPERTIES
    
    // IBOutlet
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var photoButton: UIButton!
    @IBOutlet var photoUIImage: UIImageView!
    @IBOutlet var guardarButton: UIButton!
    
    // let
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()

    
    //var
    private var nombre: String = ""
    var graficaManager = GraficaManager()
    var image: UIImage?
    
    // MARK: - FUNCTIONS
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#66B1AC")    
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

// MARK: - UIImagePickerControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate {
    @IBAction func didPhotoButtonPressed(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            photoUIImage.image = resizeImage(image: image!, targetSize: CGSize(width: 300, height: 300))
            picker.dismiss(animated: true, completion: nil)
            guardarButton.isEnabled = true
        }
}
// MARK: - UITextFieldController
extension HomeViewController: UITextViewDelegate {
    
    @IBAction func guardarPressed(_ sender: UIButton) {
        nameTextField.endEditing(true)
        if(validateField(nameTextField.text!, withRegex: nameRegex)) {
            nombre = nameTextField.text!
            addNewEntry()
            uploadImage()
            nameTextField.text = ""
            photoUIImage.image = nil
        } else {
            showAlert()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "ERROR", message: "Agrega un nombre correcto.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("Nombre incorrecto.")
        }))
        
        present(alert, animated: true)
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
