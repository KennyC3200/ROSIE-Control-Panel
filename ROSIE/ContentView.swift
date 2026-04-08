//
//  ContentView.swift
//  ROSIE
//
//  Created by Kenny Chen on 2026-03-30.
//

import SwiftUI

let gradient = RadialGradient(
    colors: [
        .bgGradientColor1,
        .bgGradientColor2
    ],
    center: UnitPoint(x: 1.1, y: 0.05),
    startRadius: 10,
    endRadius: 720)

struct ContentView: View {
    @StateObject private var BLE = BLEManager()
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TitleView()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.2)
                BluetoothView()
                    .environmentObject(BLE)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.2)
                ControllerView()
                    .environmentObject(BLE)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
            }
            .background(.white)
            .foregroundStyle(.black)
        }
    }
}
