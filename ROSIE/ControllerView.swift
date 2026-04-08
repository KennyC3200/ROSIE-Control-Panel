//
//  ControllerPage.swift
//  ROSIE
//
//  Created by Kenny Chen on 2026-03-30.
//

import SwiftUI

struct ControllerView: View {
    @EnvironmentObject var BLE: BLEManager
    @State private var motorSpeedPercent: UInt = 0
    
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    if BLE.isConnected {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Speed")
                                Spacer()
                                Text("\(BLE.motorSpeedPercent)%")
                                    .fontWeight(.semibold)
                            }
                            Divider()
                            HStack {
                                Text("Motor 1 RPM")
                                Spacer()
                                Text("\(String(BLE.motor1RPM))")
                                    .fontWeight(.semibold)
                            }
                            Divider()
                            HStack {
                                Text("Motor 2 RPM")
                                Spacer()
                                Text("\(String(BLE.motor2RPM))")
                                    .fontWeight(.semibold)
                            }
                            Divider()
                            HStack {
                                Text("Ball Spin")
                                Spacer()
                                Text("\(BLE.ballSpin ? "ON" : "OFF")")
                                    .fontWeight(.semibold)
                                    .foregroundColor(BLE.ballSpin ? .green : .red)
                            }
                            HStack(spacing: 10) {
                                Button(action: {
                                    let speedPercent = BLE.motorSpeedPercent - 5 <= 15 ? 15 : BLE.motorSpeedPercent - 5
                                    BLE.setMotorSpeedPercent(speedPercent)
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 60, height: 60)
                                        .background(.orange)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                Button(action: {
                                    let speedPercent = BLE.motorSpeedPercent + 5 > 100 ? 100 : BLE.motorSpeedPercent + 5
                                    BLE.setMotorSpeedPercent(speedPercent)
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 60, height: 60)
                                        .background(.orange)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                Button(action: {
                                    BLE.setBallSpin(!BLE.ballSpin)
                                }) {
                                    Image(systemName: "rotate.3d.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 60, height: 60)
                                        .background(.orange)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .frame(width: 0.5 * geometry.size.width)
                    } else {
                        Text("Please connect to a device.")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                
                ZStack {
                    // Outer circle
                    Circle()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.0))
                        .frame(width: 172, height: 172)
                        .opacity(0.2)
                        .phaseAnimator([false, true]) { content, phase in
                            content
                                .scaleEffect(isRecording ? (phase ? 1.0 : 1.2) : 1.0)
                        } animation: { phase in
                            isRecording ? .easeOut(duration: 1) : .default
                        }
                    
                    
                    // Middle circle
                    Circle()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.0))
                        .frame(width: 172, height: 172)
                        .opacity(0.5)
                        .phaseAnimator([false, true]) { content, phase in
                            content
                                .scaleEffect(isRecording ? (phase ? 0.9 : 1.1) : 1.0)
                        } animation: { phase in
                            isRecording ? .easeIn(duration: 1) : .default
                        }
                    
                    
                    // Inner circle
                    Circle()
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.0))
                        .frame(width: 172, height: 172)
                        .opacity(0.8)
                        .phaseAnimator([false, true]) { content, phase in
                            content
                                .scaleEffect(isRecording ? (phase ? 0.7 : 1.0) : 1.0)
                        } animation: { phase in
                            isRecording ? .easeInOut(duration: 1) : .default
                        }
                        .onTapGesture {
                            isRecording.toggle()
                        }
                    
                    
                    if (isRecording) {
                        Image(systemName: "waveform.badge.microphone")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                            .bold()
                            .symbolEffect(.variableColor.iterative.hideInactiveLayers.nonReversing, options: .repeat(.continuous))
                            .onTapGesture {
                                isRecording.toggle()
                                stopRecording()
                            }
                    } else {
                        Image(systemName: "microphone.badge.xmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                            .bold()
                            .symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
                            .onTapGesture {
                                isRecording.toggle()
                                startRecording()
                            }
                    }
                    
                }
                .blendMode(.hardLight)
                .offset(y: 0.1 * geometry.size.height)
            }
        }
    }
    
    private func startRecording() {
        print("start recording")
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
    }
    
    private func stopRecording() {
        print("stop recording")
        speechRecognizer.stopTranscribing()
        
        let transcribedText = speechRecognizer.transcript
        print(transcribedText)
    }
}
