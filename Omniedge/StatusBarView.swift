//
//  SwiftUIView.swift
//  Omniedge
//
//  Created by An Li on 2021/1/11.
//

import SwiftUI


let HIGHT: CGFloat = 300.0
let WIDTH: CGFloat = 250.0


struct StatusBarView: View {
    
    
    @State var connected = false
    var body: some View {
        VStack {
            Toggle(isOn: $connected){
                
                Text("Enable")
                Spacer()
                
            }
            .padding([.leading, .trailing])
            .toggleStyle(SwitchToggleStyle())
            
            
            Divider()
                .padding(.horizontal)
            
            
            HStack {
                Text("Hostname:")
                Spacer()
                Text("Apple-iMac-2015")
            }
            .padding([ .leading, .trailing])
            
            HStack {
                Text("IP Address:")
                Spacer()
                Text("10.253.10.23")
            }
            .padding([.top, .leading, .trailing])
            
            
            Divider()
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(1..<10) {
                        
                        ExtractedView(name: "\($0)")
                        
                    }
                }
            }
            .frame(height: 180.0)
            
            
            Divider()
            Button(action: testXPC) {
                Text("Test XPC")
            }
            
        }
        
        //        .frame(width: width, height: height)
        
        
        
    }
}
func testXPC(){
    
}
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusBarView()
        }
        
    }
}

struct ExtractedView: View {
    
    var name: String
    var body: some View {
        
       
        HStack {
            Text("10.253.10.\(name):")
            Spacer()
            Text("23ms")
        }
        .padding([.leading, .bottom, .trailing])
            
        
        
    }
}
