//
//  ContentView.swift
//  Flashzilla
//
//  Created by Jessie Chen on 17/6/2021.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled

    @State private var isActive = true
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    
    @State private var timeIsOver = false

    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showEditScreen = false
    @State private var showSettingScreen = false
    
    
    var body: some View {
        ZStack{
            Image(decorative: "background").resizable().scaledToFill().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Time: \(timeRemaining)").font(.largeTitle).foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 5).background(Capsule().fill(Color.black)).opacity(0.75)
                ZStack{
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: self.cards[index]) {
                            withAnimation {
                                self.removeCard(at: index)
                            }
                        }.stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1).accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if timeIsOver {
                    
                    Text("Time is over").foregroundColor(.white).padding().background(Capsule().fill(Color.black)).opacity(0.5)                }
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards).padding().background(Color.white).foregroundColor(.black).clipShape(Capsule())
                }
            }
            VStack {
                HStack {
                    Button(action: {
                        self.showSettingScreen = true
                    }) {
                        Image(systemName: "gear").padding().background(Color.black).clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.showEditScreen = true
                    }) {
                        Image(systemName: "plus.circle").padding().background(Color.black).clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle").padding().background(Color.black.opacity(0.7)).clipShape(Circle())}
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle").padding().background(Color.black.opacity(0.7)).clipShape(Circle())}
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                    }
                    .foregroundColor(.white).font(.largeTitle).padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard self.isActive else {return}
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            
            if self.timeRemaining == 0 {
                self.timeIsOver = true
                self.cards = []
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .sheet(isPresented: $showEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        
        .onAppear(perform: resetCards)
    }
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        cards.remove(at: index)

        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards(){
        timeIsOver = false
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try?JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}