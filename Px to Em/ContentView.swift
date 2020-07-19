//
//  ContentView.swift
//  Px to Em
//
//  Created by Karl Koch on 16/06/2020.
//  Copyright © 2020 KEJK. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UIKit

extension SceneDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

struct AdaptsToSoftwareKeyboard: ViewModifier {
    
    @State var currentHeight: CGFloat = 0


    func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight).animation(.easeOut(duration: 0.25))
            .edgesIgnoringSafeArea(currentHeight == 0 ? Edge.Set() : .bottom)
            .onAppear(perform: subscribeToKeyboardChanges)
    }

    private let keyboardHeightOnOpening = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height }

    
    private let keyboardHeightOnHiding = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map {_ in return CGFloat(0) }
    
    private func subscribeToKeyboardChanges() {
        
        _ = Publishers.Merge(keyboardHeightOnOpening, keyboardHeightOnHiding)
            .subscribe(on: RunLoop.main)
            .sink { height in
                if self.currentHeight == 0 || height == 0 {
                    self.currentHeight = height
                }
        }
    }
}

struct ContentView: View {
    @State private var show_modal: Bool = false
    @State private var show_settings_modal: Bool = false
    
    @State private var baseText = "16"
    @State private var pixelText = "16"
    @State private var scaleText = "1.000"
    @State private var baseTextEmpty = ""
    @State private var pixelTextEmpty = ""
    @State private var scaleTextEmpty = ""
    
    lazy var pixelInt = Double(pixelText) ?? 16
    lazy var baseInt = Double(baseText) ?? 16
    lazy var scaleInt = Double(scaleText) ?? 1.000
    
    func pxToEms(baseInt: Double, pixelInt: Double, scaleInt: Double) -> Double {
        let emValue = (pixelInt / baseInt) * scaleInt
        return emValue
    }
    
    let modal = UIImpactFeedbackGenerator(style: .light)
    
        var body: some View {
            VStack {
                VStack (alignment: .leading)  {
                    HStack {
                        Text("Px ›› Em").bold().padding(.top, 44)
                        .multilineTextAlignment(.leading)
                            .font(.system(.largeTitle, design: .rounded))
                            .padding()
                        Spacer()
                        Button(action: {
                            self.show_settings_modal = true
                            self.modal.impactOccurred()
                        }) {
                            Image(systemName: "square.grid.2x2.fill").padding().padding(.top, 44)
                                .font(.title)
                                .foregroundColor(Color(red: 0.00, green: 0.60, blue: 0.53, opacity: 1.0))
                        }
                        .sheet(isPresented: self.$show_settings_modal) {
                        SettingsModalView()
                    }
                    }
                    VStack (alignment: .leading) {
                        Text("Baseline pixel value").font(.headline)
                        TextField("16", text: $baseTextEmpty)
                        .font(.system(.title, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 1.00, green: 0.60, blue: 0.00, opacity: 1.0), lineWidth: 3))
                        .keyboardType(.decimalPad)
                    }.padding(20)
                VStack (alignment: .leading) {
                    HStack {
                        VStack (alignment: .leading) {
                        Text("Pixels to convert").font(.headline)
                        TextField("16", text: $pixelTextEmpty)
                        .font(.system(.title, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.00, green: 0.60, blue: 0.53, opacity: 1.0), lineWidth: 3))
                        .keyboardType(.decimalPad)
                        }.padding(.leading, 20).padding(.trailing, 20)
                        VStack (alignment: .leading) {
                            HStack {
                                Text("Scale").font(.headline)
                                Button(action: {
                                    self.show_modal = true
                                    self.modal.impactOccurred()
                                }) {
                                Image(systemName: "info.circle").padding(.leading, 16).padding(.trailing, 16)
                                    .foregroundColor(Color(red: 0.00, green: 0.60, blue: 0.53, opacity: 1.0))
                                    .font(.system(size: 20, weight: .semibold))
                                }
                                .sheet(isPresented: self.$show_modal) {
                                ScaleModalView()
                            }
                        }
                        TextField("1.000", text: $scaleTextEmpty)
                        .font(.system(.title, design: .monospaced))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.00, green: 0.60, blue: 0.53, opacity: 1.0), lineWidth: 3))
                        .keyboardType(.decimalPad)
                        }.padding(.leading, 20).padding(.trailing, 20)
                    }
                }
            }
            VStack (alignment: .center) {
                Spacer()
                Text("\(Int(pixelTextEmpty) ?? 16)px is \(String(format: "%.3f", pxToEms(baseInt: Double(baseTextEmpty) ?? 16, pixelInt: Double(pixelTextEmpty) ?? 16, scaleInt: Double(scaleTextEmpty) ?? 1)))em")
                    .font(.system(.title, design: .monospaced)).bold()
                Spacer()
            }.padding()
        }.modifier(AdaptsToSoftwareKeyboard())
    }
}

struct ScaleModalView: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            VStack {
                Image(systemName: "chevron.compact.down").font(.system(.largeTitle)).padding(.top, 20).foregroundColor(Color.gray)
                Text("Example scales").bold()
                    .font(.system(.title, design: .rounded))
                    .padding()
            }
            VStack (alignment: .leading, spacing: 16) {
                Text("Browser default: 1.000").font(.system(.body, design: .monospaced))
                Text("Minor second: 1.067").font(.system(.body, design: .monospaced))
                Text("Major second: 1.125").font(.system(.body, design: .monospaced))
                Text("Minor third: 1.200").font(.system(.body, design: .monospaced))
                Text("Major third: 1.250").font(.system(.body, design: .monospaced))
                Text("Perfect fourth: 1.333").font(.system(.body, design: .monospaced))
                Text("Augmented fourth: 1.414").font(.system(.body, design: .monospaced))
                Text("Perfect fifth: 1.500").font(.system(.body, design: .monospaced))
                Text("Golden ratio: 1.618").font(.system(.body, design: .monospaced))
                }.padding()
            Spacer()
        }
    }
}

struct SettingsModalView: View {
    enum BMAppIcon: CaseIterable {
        case classic,
        innerShadow,
        neuomorphic,
        gradient,
        shadow,
        white,
        black

        var name: String? {
            switch self {
               case .classic:
                    return nil
                case .innerShadow:
                    return "innerShadowIcon"
                case .neuomorphic:
                    return "neuomorphicIcon"
                case .gradient:
                    return "gradientIcon"
                case .shadow:
                    return "shadowIcon"
                case .white:
                    return "whiteIcon"
                case .black:
                return "blackIcon"
            }
        }

        var preview: UIImage {
            switch self {
                case .classic:
                    return #imageLiteral(resourceName: "classic")
                case .innerShadow:
                    return #imageLiteral(resourceName: "innerShadow")
                case .neuomorphic:
                    return #imageLiteral(resourceName: "neuomorphic")
                case .gradient:
                    return #imageLiteral(resourceName: "gradient")
                case .shadow:
                    return #imageLiteral(resourceName: "shadow")
                case .white:
                    return #imageLiteral(resourceName: "white")
                case .black:
                    return #imageLiteral(resourceName: "black")
            }
        }
    }
    
    var current: BMAppIcon {
         return BMAppIcon.allCases.first(where: {
           $0.name == UIApplication.shared.alternateIconName
         }) ?? .classic
       }

       func setIcon(_ appIcon: BMAppIcon, completion: ((Bool) -> Void)? = nil) {
         
         guard current != appIcon,
           UIApplication.shared.supportsAlternateIcons
           else { return }
               
         UIApplication.shared.setAlternateIconName(appIcon.name) { error in
           if let error = error {
             print("Error setting alternate icon \(appIcon.name ?? ""): \(error.localizedDescription)")
           }
           completion?(error != nil)
         }
       }
    
    let success = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack (alignment: .center, spacing: 16) {
            VStack {
                Image(systemName: "chevron.compact.down").font(.system(.largeTitle)).padding(.top, 20).foregroundColor(Color.gray)
                Text("Change app icon").bold()
                    .font(.system(.title, design: .rounded))
                    .padding()
            }
            VStack (alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: {
                        self.setIcon(.classic)
                        self.success.impactOccurred()
                    }) {
                    Text("Default")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image("classic")
                    .renderingMode(.original)
                    .cornerRadius(15)
                    }
                }
                HStack {
                    Button(action: {
                        self.setIcon(.innerShadow)
                        self.success.impactOccurred()
                    }) {
                    Text("Inner Shadow")
                        .foregroundColor(Color.primary)
                    Spacer()
                    
                    Image("innerShadow")
                    .renderingMode(.original)
                    .cornerRadius(15)
                        
                    }
                }
                HStack {
                    Button(action: {
                        self.setIcon(.neuomorphic)
                        self.success.impactOccurred()
                    }) {
                    Text("Neuomorphic")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image("neuomorphic")
                    .renderingMode(.original)
                    .cornerRadius(15)
                    }
                }
                HStack {
                    Button(action: {
                        self.setIcon(.gradient)
                        self.success.impactOccurred()
                    }) {
                        Text("Gradient")
                            .foregroundColor(Color.primary)
                    Spacer()
                    Image("gradient")
                    .renderingMode(.original)
                    .cornerRadius(15)
                    }
                }
                HStack {
                    Button(action: {
                        self.setIcon(.shadow)
                        self.success.impactOccurred()
                    }) {
                    Text("Shadow")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image("shadow")
                    .renderingMode(.original)
                    .cornerRadius(15)
                    }
                }
                HStack {
                    Button(action: {
                        self.setIcon(.white)
                        self.success.impactOccurred()
                    }) {
                    Text("White")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image("white")
                    .renderingMode(.original)
                    .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(red: 0.00, green: 0.60, blue: 0.53, opacity: 0.4), lineWidth: 1))
                    }
                }
                HStack {
                    Button(action: {
                        self.setIcon(.black)
                        self.success.impactOccurred()
                    }) {
                    Text("Black")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image("black")
                    .renderingMode(.original)
                    .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(red: 0.00, green: 0.60, blue: 0.53, opacity: 0.4), lineWidth: 1))
                    }
                }
            }.padding()
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
