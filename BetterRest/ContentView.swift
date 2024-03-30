//
//  ContentView.swift
//  BetterRest
//
//  Created by Venkata on 3/28/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var sleepTime = defaultWakeTime
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("When do You want wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) { _ in calculateBedtime() }
                }
                
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { _ in calculateBedtime() }
                }
                
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("\($0)")
                        }
                    }
                    .onChange(of: coffeeAmount) { _ in calculateBedtime() }
                }
                
                Section{
                    Text("Your ideal  bedtime is \(sleepTime.formatted(date: .omitted, time: .shortened))")
                        .font(.largeTitle)
                }
            }
            .navigationTitle("Better Rest")
            .onAppear(perform: calculateBedtime)
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour+minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            
            sleepTime = wakeUp - prediction.actualSleep
            
        } catch {
            print("error")
        }
    }
}

#Preview {
    ContentView()
}
