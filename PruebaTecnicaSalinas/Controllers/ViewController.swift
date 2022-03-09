//
//  ViewController.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 07/03/22.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseStorage
import Charts
import TinyConstraints

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - PROPERTIES
    
    // IBOutlet
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var photoButton: UIButton!
    
    // let
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()

    
    //var
    private var nombre: String = ""
    var graficaManager = GraficaManager()
    var image: UIImage?
    lazy var pieChart: PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = .systemBlue
        return chartView
    }()
    //var barChart = BarChartView()
    
    // MARK: - FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graficaManager.delegate = self
        
        graficaManager.fetchGrafica()
        
        view.backgroundColor = UIColor(hexString: "#66B1AC")
        
        pieChart.delegate = self
        
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
          //  for question in grafica.questions {
            //    self.generateChart(options: question.options)
           // }
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
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
// MARK: - ChartViewDelegate
extension ViewController: ChartViewDelegate {
    override func viewDidLayoutSubviews() {
     //   super.viewDidLayoutSubviews()
        
        view.addSubview(pieChart)
        pieChart.centerInSuperview()
        pieChart.width(to: view)
        pieChart.height(600)
       
        var entries = [ChartDataEntry]()
        
        for x in 0..<10 {
            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
        }
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
        pieChart.data = data
    }
}
