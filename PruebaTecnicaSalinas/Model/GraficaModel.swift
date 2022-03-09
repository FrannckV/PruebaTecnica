//
//  graficasModel.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 07/03/22.
//

import Foundation

struct GraficaModel {
    let questions: [Question]
}

struct Question {
    let text: String
    let total: Int
    let options: [Options]
}

struct Options {
    let text: String
    let percetnage: Int
    let color: String
    
    // MARK: - COMPUTED PROPERTIES
    var percetnageDouble: Double {
        return Double(percetnage) * 0.1
    }
}
