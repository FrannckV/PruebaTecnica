//
//  GraficasViewController.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 09/03/22.
//

import UIKit
import Charts
import TinyConstraints

class GraficasViewController: UIViewController {
    
    //var
    var graficaManager = GraficaManager()
    var entries = [ChartDataEntry]()
    lazy var pieChart: PieChartView = {
        let chartView = PieChartView()
        chartView.backgroundColor = .systemBlue
        return chartView
    }()
    
    // MARK: - FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graficaManager.delegate = self
        graficaManager.fetchGrafica()
        pieChart.delegate = self
        
    }
}
// MARK: - GraficaManagerDelegate
extension GraficasViewController: GraficaManagerDelegate {
    func didUpdateGraficas(_ graficasManager: GraficaManager, grafica: GraficaModel) {
        DispatchQueue.main.async {
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
extension GraficasViewController: ChartViewDelegate {
    override func viewDidLayoutSubviews() {
       view.addSubview(pieChart)
        pieChart.centerInSuperview()
        pieChart.width(to: view)
        pieChart.heightToWidth(of: view)
    
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

