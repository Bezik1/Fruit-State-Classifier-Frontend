//
//  Models.swift
//  Fruit Quality Scanner Frontend
//
//  Created by MacBook Mateusz Adamowicz on 08/08/2025.
//


import Foundation

struct PixelData: Codable {
    let pixels: [[[Int]]]
}

struct PredictionResponse: Codable {
    let status: Int
    let message: String
    let data: PredictionData?
}

struct PredictionData: Codable {
    let probability: Double
    let fruit_state: String
}
