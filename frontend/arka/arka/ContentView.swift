import SwiftUI
import CoreData
import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding(12)
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.7))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            if !message.isUser { Spacer() }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var messages: [ChatMessage] = []
    @State private var instruction = ""
    @State private var additionalInput = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Exit button
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding()
            }
            
            // Chat messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(Color(NSColor.windowBackgroundColor))
            
            // Input area
            VStack(spacing: 12) {
                TextField("Enter instruction...", text: $instruction)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                TextField("Enter additional information...", text: $additionalInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button(action: sendMessage) {
                        Text("Send")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 600, minHeight: 400) // Set the minimum size for the content view
        .background(Color(NSColor.windowBackgroundColor))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func sendMessage() {
        guard !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: instruction, isUser: true)
        messages.append(userMessage)
        
        let url = URL(string: "https://8699-34-142-212-207.ngrok-free.app/predict")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: String] = [
            "instruction": instruction,
            "input": additionalInput,
            "output": ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data in response")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseText = json["response"] as? String {
                    DispatchQueue.main.async {
                        let botResponse = ChatMessage(content: responseText, isUser: false)
                        messages.append(botResponse)
                    }
                }
            } catch {
                print("Error parsing JSON response: \(error)")
            }
        }.resume()
        
        instruction = ""
        additionalInput = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
