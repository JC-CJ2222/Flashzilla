//
//  Setting.swift
//  Flashzilla
//
//  Created by Jessie Chen on 19/6/2021.
//

import SwiftUI

struct Setting: View {
    @Environment (\.presentationMode) var presentationMode
    @State private var insertIncorrectCards = false
    
    var body: some View {
        NavigationView {
            List {
                Toggle("Insert back incorrect cards", isOn: $insertIncorrectCards)
            
                if insertIncorrectCards {
                    Text("hi")
                }
            }
            .navigationTitle(Text("Setting"))
            .navigationBarItems(trailing: Button("Done", action: dismiss)).listStyle(GroupedListStyle())
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
    
    func dismiss(){
        presentationMode.wrappedValue.dismiss()
    }
}

struct Setting_Previews: PreviewProvider {
    static var previews: some View {
        Setting()
    }
}
