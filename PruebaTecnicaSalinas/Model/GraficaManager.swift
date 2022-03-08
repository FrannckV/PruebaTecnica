//
//  graficasManager.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 07/03/22.
//

import Foundation
import CoreLocation

protocol GraficaManagerDelegate {
    func didUpdateGraficas(_ graficasManager: GraficaManager, grafica: GraficaModel)
    func didFailWithError(error: Error)
}

struct GraficaManager {
    let graficasURL = "https://us-central1-bibliotecadecontenido.cloudfunctions.net/helloWorld"
    
    var delegate: GraficaManagerDelegate?
    
    func fetchGrafica() {
        performRequest(with: graficasURL)
    }
    
    func performRequest (with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let grafica = parseJSON(safeData) {
                        delegate?.didUpdateGraficas(self, grafica: grafica)
                    }
                }
            }

            task.resume()
        }
    }
    
    func parseJSON(_ graficaData: Data) -> GraficaModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(GraficaData.self, from: graficaData)
            var questions: [Question] = []
            
            for q in decodedData.questions {
                let text = q.text
                let total = q.total
                var opcs: [Options] = []
                
                for o in q.chartData {
                    opcs.append(Options(text: o.text, percetnage: o.percetnage, color: decodedData.colors.randomElement()!))
                }
                questions.append(Question(text: text, total: total, options: opcs))
            }
           
            let grafica = GraficaModel(questions: questions)
            return grafica
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
