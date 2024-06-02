//
//  ContentView.swift
//  BetterRest
//
//  Created by Hrishikesh on 01/06/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var sleepTime = Date.now
    
    @State private var alertTitle = ""
    @State private var alertMessage=""
    @State private var showingAlert = false
    @State private var showingResult = false
    
    
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double (hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            sleepTime = wakeUp - prediction.actualSleep
            showingResult = true
            
        } catch {
            // something went wrong
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(stops: [
                    Gradient.Stop(color: .orange, location: 0.20),
                    .init(color: .yellow, location: 0.43),
                    .init(color: .pink, location: 1.05),
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                VStack {
//                    GeometryReader { proxy in
//                        Image("Piggy")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: proxy.size.width * 0.5, alignment: .center)
//                    }
                    Spacer()
                    Image("Piggy")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.68)
                        .padding(.horizontal)
                        .clipShape(.circle)

                    
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) {
                                showingResult = false
                        }
                    
                    Text("Desired amount of sleep")
                        .font(.headline)
                        .padding(.top, 20)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.68)
                        .onChange(of: sleepAmount) {
                            showingResult = false
                    }
                    
                    Text("Daily coffee intake")
                        .font(.headline)
                        .padding(.top, 20)
                    Stepper("^[\(coffeeAmount) cup](inflect:true)", value: $coffeeAmount, in: 0...20)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.68)
                        .onChange(of: coffeeAmount) {
                            showingResult = false
                    }
                    Spacer()
                    if showingResult{
                        Text("Sleep time \(sleepTime.formatted(date: .omitted, time: .shortened))")
                            .font(.headline)
                    } else {
                        Text("Sleep time \(sleepTime.formatted(date: .omitted, time: .shortened))")
                            .font(.headline)
                            .hidden()
                    }
                    Spacer()
                }
                .navigationTitle("BetterRest")
                .toolbar {
                    Button("Calculate", action: calculateBedTime)
                        .tint(.primary)
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
