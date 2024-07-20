import SwiftUI

struct WelcomeScreen: View {
    @State private var navigateToChat = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Arka")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Image(systemName: "message.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.blue)
            
            Button(action: {
                navigateToChat = true
            }) {
                Text("Enter Chat")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $navigateToChat) {
            ContentView()
        }
    }
}
