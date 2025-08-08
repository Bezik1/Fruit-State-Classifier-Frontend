import SwiftUI
import AppKit

struct ContentView: View {
    @State private var image: NSImage? = nil
    @State private var predictionResult: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Button(action: selectImage) {
                Group {
                    if let image = image {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 400, maxHeight: 400)
                            .cornerRadius(15)
                            .shadow(radius: 6)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .frame(width: 400, height: 400)
                            .overlay(
                                Text("No image selected")
                                    .font(.custom("Marker Felt", size: 18))
                                    .foregroundColor(.secondary)
                                    .italic()
                            )
                    }
                }
                .frame(width: 400, height: 400)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.clear)
            
            Button(action: {
                Task {
                    await predictFruitQuality()
                }
            }) {
                Text("Predict Fruit Quality")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .font(.custom("Verdana", size: 14))
                    .background(Color.section)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 40)
            .disabled(image == nil || isLoading)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 10)
            }
            
            if !predictionResult.isEmpty {
                Text(predictionResult)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer(minLength: 20)
        }
        .frame(width: 420, height: 650)
        .foregroundColor(Color.border)
        .padding()
        .background(Color.background)
        .animation(.easeInOut, value: predictionResult)
        .animation(.easeInOut, value: errorMessage)
    }
    
    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .heic, .tiff]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK,
           let url = panel.url,
           let nsImage = NSImage(contentsOf: url) {
            predictionResult = ""
            errorMessage = ""
            image = nsImage
        }
    }
    
    func predictFruitQuality() async {
        guard let image = image else {
            errorMessage = "Please select an image first!"
            return
        }
        
        predictionResult = ""
        errorMessage = ""
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            let response = try await PredictionService.shared.getPrediction(image: image)
            
            if response.status == 200, let data = response.data {
                predictionResult = "Fruit State: \(data.fruit_state)\nProbability: \(String(format: "%.2f", data.probability))%"
            } else {
                errorMessage = "Server error: \(response.message)"
            }
        } catch {
            if let predictionError = error as? PredictionError {
                errorMessage = predictionError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
