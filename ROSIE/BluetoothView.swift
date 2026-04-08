//
//  BluetoothPage.swift
//  ROSIE
//
//  Created by Kenny Chen on 2026-03-30.
//

import SwiftUI

struct BluetoothView: View {
    @EnvironmentObject var BLE: BLEManager
    
    var body: some View {
        VStack {
            if BLE.discoveredPeripherals.isEmpty {
                Spacer()
                HStack(alignment: .bottom, spacing: 1) {
                    Text("Scanning for devices")
                        .font(.headline)
                        .fontWeight(.medium)
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .fontWeight(.medium)
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                        .offset(y: -2)
                }
                Spacer()
            } else {
                List(BLE.discoveredPeripherals, id: \.peripheral.identifier) { e in
                    HStack {
                        VStack(alignment: .leading) {
                            // TODO: Why the fuck does it cache the name so have to hardcode it for now
                            Text("R.O.S.I.E MK1")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text("\(e.rssi) dBm")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Button(action: {
                            if !BLE.isConnected {
                                BLE.connect(e.peripheral)
                            } else {
                                BLE.disconnect()
                            }
                        }) {
                            Image(systemName: BLE.isConnected ? "personalhotspot.slash" : "link")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.wholeSymbol), options: .nonRepeating))
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.orange)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { BLE.startScanning() })
            print("Started scanning")
        }
        .onDisappear {
            BLE.stopScanning()
            print("Stopped scanning")
        }
    }
}
