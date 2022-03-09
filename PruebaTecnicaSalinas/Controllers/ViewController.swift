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
    var entries = [ChartDataEntry]()
    lazy var pieChart: PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = .systemBlue
        return chartView
    }()
    
    // MARK: - FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //graficaManager.delegate = self
        
        graficaManager.fetchGrafica()
        
        view.backgroundColor = UIColor(hexString: "#66B1AC")
        
       // pieChart.delegate = self
        
     }
    
    @IBAction func didPhotoButtonPressed(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
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
/*// MARK: - GraficaManagerDelegate
extension ViewController: GraficaManagerDelegate {
    func didUpdateGraficas(_ graficasManager: GraficaManager, grafica: GraficaModel) {
        DispatchQueue.main.async {
            // Acomodar las cosas en la gráfica
          //  for question in grafica.questions {
            //    self.generateChart(options: question.options)
           // }
            self.fillEntries(opciones: grafica.questions[0].options)
            
            print("--------------- SUCCESS --------------------")
            self.viewDidLayoutSubviews()
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

// MARK: - ChartViewDelegate




extension ViewController: ChartViewDelegate {
    override func viewDidLayoutSubviews() {
        view.addSubview(pieChart)
        pieChart.centerInSuperview()
        pieChart.width(to: view)
        pieChart.height(600)
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
        pieChart.data = data
        print("--------------- FILLED --------------------")
    }
    
    func fillEntries(opciones: [Options]) {
        for o in opciones {
            entries.append(ChartDataEntry(x: 0.0, y: o.percetnageDouble, data: o.text))
        }
    }
}
*/
