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
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var photoButton: UIButton!
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    private var nombre: String = ""
    
    var graficaManager = GraficaManager()
    
    var image: UIImage?
    
    //var startAngle: CGFloat = -(.pi / 2)
    
    //let shape = CAShapeLayer()
    //var shapes = [CAShapeLayer]()
    
    /*private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Titulo"
        label.font = .systemFont(ofSize: 3, weight: .light)
        return label
    }()*/
    
    lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = .systemBlue
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graficaManager.delegate = self
        
        graficaManager.fetchGrafica()
        
//        view.backgroundColor = UIColor(hex: getColor(color: K.colorBlueChild))
        view.backgroundColor = UIColor(hexString: "#66B1AC")
        
        view.addSubview(pieChartView)
        pieChartView.centerInSuperview()
        pieChartView.width(to: view)
        pieChartView.heightToWidth(of: view)
        
        
        self.title = "Half Pie Chart"
                
               /* self.options = [.toggleValues,
                                .toggleXValues,
                                .togglePercent,
                                .toggleHole,
                                .animateX,
                                .animateY,
                                .animateXY,
                                .spin,
                                .drawCenter,
                                .saveToGallery,
                                .toggleData]
                
                self.setup(pieChartView: pieChartView)*/
                
                pieChartView.delegate = self
                
                pieChartView.holeColor = .white
                pieChartView.transparentCircleColor = NSUIColor.white.withAlphaComponent(0.43)
                pieChartView.holeRadiusPercent = 0.58
                pieChartView.rotationEnabled = false
                pieChartView.highlightPerTapEnabled = true
                
                pieChartView.maxAngle = 180 // Half chart
                pieChartView.rotationAngle = 180 // Rotate to make the half on the upper side
                pieChartView.centerTextOffset = CGPoint(x: 0, y: -20)
                
                let l = pieChartView.legend
                l.horizontalAlignment = .center
                l.verticalAlignment = .top
                l.orientation = .horizontal
                l.drawInside = false
                l.xEntrySpace = 7
                l.yEntrySpace = 0
                l.yOffset = 0
        //        pieChartView.legend = l
                // entry label styling
                pieChartView.entryLabelColor = .white
                pieChartView.entryLabelFont = UIFont(name:"HelveticaNeue-Light", size:12)!
                
                self.updateChartData()
                
                pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
    }
    
   /* @objc func didTapButton() {
        let animation = CABasicAnimation(keyPath: K.strokeEnd)
        animation.toValue = 1
        animation.duration = 5
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        for shape in shapes {
            shape.add(animation, forKey: K.animationKey)
        }
        
    }*/
    
    @IBAction func didPhotoButtonPressed(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }
    /*func generateChart(options: [Options]){
        
        label.sizeToFit()
        view.addSubview(label)
        label.center = view.center
        
        let circleBackground = UIBezierPath(arcCenter: view.center,
                                      radius: 150,
                                      startAngle: -(.pi / 2),
                                      endAngle: (.pi * 2),
                                      clockwise: true)
        let trackShape = CAShapeLayer()
        trackShape.path = circleBackground.cgPath
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.lineWidth = 15
        trackShape.strokeColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(trackShape)
        
        for op in options {
            let endAngle = (.pi * 2 * op.percetnageDegrees) / 360
            let circlePath = UIBezierPath(arcCenter: view.center,
                                          radius: 150,
                                          startAngle: startAngle,
                                          endAngle: endAngle,
                                          clockwise: true)
            
            shape.path = circlePath.cgPath
            shape.lineWidth = 15
            shape.strokeColor = UIColor(hexString: op.color).cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeEnd = 0
            
            startAngle = endAngle
            
            shapes.append(shape)
        }
        for shape in shapes {
            view.layer.addSublayer(shape)
        }
        let button = UIButton(frame: CGRect(x: 20, y: view.frame.size.height-70, width: view.frame.size.width-40, height: 50))
        view.addSubview(button)
        button.setTitle("Animate", for: .normal)
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
    }*/
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
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func updateChartData() {
            /*if shouldHideData {
                pieChartView.data = nil
                return
            }*/
            
            self.setData(4, range: 100)
        }
    /*func optionTapped(_ option: Option) {
            switch option {
            case .toggleXValues:
                pieChartView.drawEntryLabelsEnabled = !pieChartView.drawEntryLabelsEnabled
                pieChartView.setNeedsDisplay()
                
            case .togglePercent:
                pieChartView.usePercentValuesEnabled = !pieChartView.usePercentValuesEnabled
                pieChartView.setNeedsDisplay()
                
            case .toggleHole:
                pieChartView.drawHoleEnabled = !pieChartView.drawHoleEnabled
                pieChartView.setNeedsDisplay()
                
            case .drawCenter:
                pieChartView.drawCenterTextEnabled = !pieChartView.drawCenterTextEnabled
                pieChartView.setNeedsDisplay()
                
            case .animateX:
                pieChartView.animate(xAxisDuration: 1.4)
                
            case .animateY:
                pieChartView.animate(yAxisDuration: 1.4)
                
            case .animateXY:
                pieChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4)
                
            case .spin:
                pieChartView.spin(duration: 2,
                               fromAngle: pieChartView.rotationAngle,
                               toAngle: pieChartView.rotationAngle + 360,
                               easingOption: .easeInCubic)
                
            default:
                print("nothing")
                //handleOption(option, forChartView: pieChartView)
            }
        }*/
    
    func setData(_ count: Int, range: UInt32) {
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
                    // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
                    return PieChartDataEntry(value: Double(arc4random_uniform(range) + range / 5),
                                             label: "HI")//parties[i % parties.count])
                }
                
                let set = PieChartDataSet(entries: entries, label: "Election Results")
                set.sliceSpace = 3
                set.selectionShift = 5
                set.colors = ChartColorTemplates.material()
                
                let data = PieChartData(dataSet: set)
                
                let pFormatter = NumberFormatter()
                pFormatter.numberStyle = .percent
                pFormatter.maximumFractionDigits = 1
                pFormatter.multiplier = 1
                pFormatter.percentSymbol = " %"
                data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            
                data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 11)!)
                data.setValueTextColor(.white)
                
                pieChartView.data = data
                
                pieChartView.setNeedsDisplay()
    }
}
