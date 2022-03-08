//
//  graficasData.swift
//  PruebaTecnicaSalinas
//
//  Created by Frannck Villanueva on 07/03/22.
//

import Foundation

struct GraficaData: Codable {
    let colors: [String]
    let questions: [Questions]
}

struct Questions: Codable {
    let total: Int
    let text: String
    let chartData: [ChartData]
}

struct ChartData: Codable {
    let text: String
    let percetnage: Int
}
