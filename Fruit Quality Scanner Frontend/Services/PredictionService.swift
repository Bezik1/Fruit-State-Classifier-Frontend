//
//  PredictionService.swift
//  Fruit Quality Scanner Frontend
//
//  Created by MacBook Mateusz Adamowicz on 08/08/2025.
//


import Foundation
import AppKit

final class PredictionService {
    static let shared = PredictionService()
    private init() {}

    func imageToPixels(_ image: NSImage) -> [[[Int]]]? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        let width = Int(bitmap.pixelsWide)
        let height = Int(bitmap.pixelsHigh)
        
        var pixels = Array(repeating: Array(repeating: [0, 0, 0], count: width), count: height)
        
        for y in 0..<height {
            for x in 0..<width {
                let color = bitmap.colorAt(x: x, y: y) ?? NSColor.black
                let rgbColor = color.usingColorSpace(.deviceRGB) ?? NSColor.black
                
                let red = Int(rgbColor.redComponent * 255)
                let green = Int(rgbColor.greenComponent * 255)
                let blue = Int(rgbColor.blueComponent * 255)
                
                pixels[y][x] = [red, green, blue]
            }
        }
        return pixels
    }
    
    func getPrediction(image: NSImage) async throws -> PredictionResponse {
        guard let pixels = imageToPixels(image) else {
            throw PredictionError.imageConversionFailed
        }
        
        let pixelData = PixelData(pixels: pixels)
        
        guard let url = URL(string: "\(API_URL)/predict") else {
            throw PredictionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(pixelData)
            request.httpBody = jsonData
        } catch {
            throw PredictionError.decodingFailed(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // Możesz rozszerzyć o obsługę kodów błędów serwera
                throw PredictionError.serverError(message: "Unprecedented server status code")
            }
            
            do {
                let decoded = try JSONDecoder().decode(PredictionResponse.self, from: data)
                return decoded
            } catch {
                throw PredictionError.decodingFailed(error)
            }
            
        } catch {
            throw PredictionError.networkError(error)
        }
    }
}
