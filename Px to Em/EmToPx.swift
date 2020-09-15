//
//  EmToPx.swift
//  Px ›› Em
//
//  Created by Karl Koch on 21/07/2020.
//  Copyright © 2020 KEJK. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UIKit

struct EmToPx: View {
    @AppStorage("result", store: UserDefaults(suiteName: "group.com.kejk.px-to-em"))
    var resultData: Data = Data()
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    @State private var show_modal: Bool = false
    
    @State private var baseText = "16"
    @State private var emText = "1"
    @State private var scaleText = "1.000"
    @State private var baseTextEmpty = ""
    @State private var emTextEmpty = ""
    @State private var scaleTextEmpty = ""
    
    lazy var emInt = Double(emText) ?? 1
    lazy var baseInt = Double(baseText) ?? 16
    lazy var scaleInt = Double(scaleText) ?? 1.000
    
    func emToPxs(baseInt: Double, emInt: Double, scaleInt: Double) -> Double {
        let pxValue = (emInt * baseInt) / scaleInt
        return pxValue
    }
    
    func save(_ calcResult: String) {
        guard let calculation = try? JSONEncoder().encode(calcResult) else { return }
        self.resultData = calculation
        print("\(String(format: "%.2f", (Double(emTextEmpty) ?? 1.000)))em is \(String(format: "%.0f", emToPxs(baseInt: Double(baseTextEmpty) ?? 16, emInt: Double(emTextEmpty) ?? 1, scaleInt: Double(scaleTextEmpty) ?? 1)))px at a scale of \(String(format: "%.3f", (Double(scaleTextEmpty) ?? 1))) with a baseline of \(Int(baseTextEmpty) ?? 16)px")
    }
    
    let modal = UIImpactFeedbackGenerator(style: .light)
    
    let save = UINotificationFeedbackGenerator()
    @State private var saveAlert = false
    
    var device = UIDevice.current.userInterfaceIdiom
    
        var body: some View {
            VStack {
                VStack (alignment: .leading)  {
                    Text("Em ›› Px").bold().padding()
                    .multilineTextAlignment(.leading)
                        .font(.system(.largeTitle, design: .rounded))

                    VStack (alignment: .leading) {
                        Text("Baseline pixel value").font(.headline)
                        TextField("16", text: $baseTextEmpty)
                        .font(.system(.title, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("teal"), lineWidth: 3))
                        .keyboardType(.decimalPad)
                    }.padding(20)
                VStack (alignment: .leading) {
                    HStack {
                        VStack (alignment: .leading) {
                        Text("Ems").font(.headline)
                        TextField("1.00", text: $emTextEmpty)
                        .font(.system(.title, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("orange"), lineWidth: 3))
                        .keyboardType(.decimalPad)
                        }.padding(.leading, 20).padding(.trailing, 20)
                        VStack (alignment: .leading) {
                            HStack {
                                Text("Scale").font(.headline)
                                Button(action: {
                                    self.show_modal = true
                                    if device == .phone {
                                    self.modal.impactOccurred()
                                    }
                                }) {
                                Image(systemName: "info.circle").padding(.leading, 16).padding(.trailing, 16)
                                    .foregroundColor(Color("orange"))
                                    .font(.system(size: 20, weight: .semibold))
                                }
                                .sheet(isPresented: self.$show_modal) {
                                ScaleModalView()
                            }
                        }
                        TextField("1.000", text: $scaleTextEmpty)
                        .font(.system(.title, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("orange"), lineWidth: 3))
                        .keyboardType(.decimalPad)
                        }.padding(.leading, 20).padding(.trailing, 20)
                    }
                }
            }
            ZStack {
                Rectangle()
                    .fill(Color("shape"))
                VStack (alignment: .center) {
                    Spacer()
                    Text("\(String(format: "%.2f", (Double(emTextEmpty) ?? 1.000)))em is \(String(format: "%.0f", emToPxs(baseInt: Double(baseTextEmpty) ?? 16, emInt: Double(emTextEmpty) ?? 1, scaleInt: Double(scaleTextEmpty) ?? 1)))px")
                        .font(.system(.title, design: .monospaced)).bold()
                    Spacer()
                    VStack {
                        Button(action: {
                            save("\(String(format: "%.2f", (Double(emTextEmpty) ?? 1.000)))em is \(String(format: "%.0f", emToPxs(baseInt: Double(baseTextEmpty) ?? 16, emInt: Double(emTextEmpty) ?? 1, scaleInt: Double(scaleTextEmpty) ?? 1)))px at a scale of \(String(format: "%.3f", (Double(scaleTextEmpty) ?? 1))) with a baseline of \(Int(baseTextEmpty) ?? 16)px")
                                if device == .phone {
                                save.notificationOccurred(.success)
                                }
                                self.saveAlert = true
                            resetDefaults()
                        }, label: {
                            Text("Save result to widget").foregroundColor(.white).bold()
                        })
                        .alert(isPresented: self.$saveAlert, content: {
                                Alert(title: Text("Saved to widget!"), message: Text("The update won't always appear instantly"), dismissButton: .default(Text("Dismiss")))
                            })
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color("orange"))
                        .clipShape(Capsule())
                        }
                    Spacer()
                }.padding()
            }
        }
    }
}

struct EmToPx_Previews: PreviewProvider {
    static var previews: some View {
        EmToPx()
    }
}
