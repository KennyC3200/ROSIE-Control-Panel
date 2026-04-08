//
//  BLEManager.swift
//  ROSIE
//
//  Created by Kenny Chen on 2026-03-30.
//

import CoreBluetooth

class BLECharacteristic {
    var characteristic: CBCharacteristic?
    var UUID: CBUUID
    
    init(characteristic: CBCharacteristic? = nil, UUID: String) {
        self.characteristic = characteristic
        self.UUID = CBUUID(string: UUID)
    }
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected: Bool = false
    @Published var motorSpeedPercent: UInt = 0
    @Published var motor1RPM: UInt = 0
    @Published var motor2RPM: UInt = 0
    @Published var ballSpin: Bool = true
    
    @Published var discoveredPeripherals: [(peripheral: CBPeripheral, rssi: Int)] = []

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    let serviceUUID = CBUUID(string: "c82088ae-79eb-4e15-9e11-87dd59d897d5")
    
    var motorSpeedPercentChar = BLECharacteristic(characteristic: nil, UUID: "7e77c276-cd8d-4b29-bfcf-ea1bb488a49b")
    var motor1RPMChar = BLECharacteristic(characteristic: nil, UUID: "76bd9c05-8508-4ade-91ea-cab8a83a5cac")
    var motor2RPMChar = BLECharacteristic(characteristic: nil, UUID: "d7bc8ea0-ceed-4534-a6e1-88061f51ae37")
    var ballSpinChar = BLECharacteristic(characteristic: nil, UUID: "775c47cf-69c4-4ec7-bde0-0e49e75fdebe")

    override init() {
        super.init()
        
#if targetEnvironment(simulator)
        print("BLE blocked on simulator")
#else
        centralManager = CBCentralManager(delegate: self, queue: nil)
#endif
    }
    
    // Start scanning once BT is initialized
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on")
        case .poweredOff:
            print("Bluetooth is off")
        case .unauthorized:
            print("Bluetooth unauthorized")
        case .unsupported:
            print("Bluetooth not supported on this device")
        case .resetting:
            print("Bluetooth is resetting")
        case .unknown:
            print("Bluetooth state unknown")
        @unknown default:
            print("Unknown")
        }
    }
    
    // Scan for bluetooth devices
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [serviceUUID])
    }
    
    // Stop scanning for bluetooth devices
    func stopScanning() {
        centralManager.stopScan()
    }
    
    // Connect to peripheral
    func connect(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral)
    }
    
    // Disconnect from peripheral
    func disconnect() {
        centralManager.cancelPeripheralConnection(self.peripheral)
    }
    
    // When a peripheral is discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        if !discoveredPeripherals.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredPeripherals.append((peripheral, RSSI.intValue))
        }
    }
    
    // Find services once connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true // Signal for UI to update
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    // When disconnected, resume the scan for peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
    }
    
    // Discover characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else { return }
        peripheral.discoverCharacteristics([
            motorSpeedPercentChar.UUID,
            motor1RPMChar.UUID, motor2RPMChar.UUID,
            ballSpinChar.UUID
        ], for: service)
    }
    
    // Store the characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        motorSpeedPercentChar.characteristic = service.characteristics?.first(where: { $0.uuid == motorSpeedPercentChar.UUID })
        motor1RPMChar.characteristic = service.characteristics?.first(where: { $0.uuid == motor1RPMChar.UUID })
        motor2RPMChar.characteristic = service.characteristics?.first(where: { $0.uuid == motor2RPMChar.UUID })
        ballSpinChar.characteristic = service.characteristics?.first(where: { $0.uuid == ballSpinChar.UUID})
        
        peripheral.readValue(for: motorSpeedPercentChar.characteristic!)
        peripheral.readValue(for: motor1RPMChar.characteristic!)
        peripheral.readValue(for: motor2RPMChar.characteristic!)
        peripheral.readValue(for: ballSpinChar.characteristic!)
        
        peripheral.setNotifyValue(true, for: motorSpeedPercentChar.characteristic!)
        peripheral.setNotifyValue(true, for: motor1RPMChar.characteristic!)
        peripheral.setNotifyValue(true, for: motor2RPMChar.characteristic!)
        peripheral.setNotifyValue(true, for: ballSpinChar.characteristic!)
    }
    
    // When characteristics updates
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let data = characteristic.value,
              let stringVal = String(data: data, encoding: .utf8) else { return }

        switch characteristic.uuid {
        case motorSpeedPercentChar.UUID: motorSpeedPercent = UInt(stringVal) ?? 0
        case motor1RPMChar.UUID: motor1RPM = UInt(stringVal) ?? 0
        case motor2RPMChar.UUID: motor2RPM = UInt(stringVal) ?? 0
        case ballSpinChar.UUID: ballSpin = stringVal == "1"
        default: break
        }
    }

    // Set the motor speed
    func setMotorSpeedPercent(_ speed: UInt) {
        guard let char = motorSpeedPercentChar.characteristic else { return }
        guard isConnected else { return }
        
        let str = String(speed)
        let data = Data(str.utf8)
        peripheral.writeValue(data, for: char, type: .withoutResponse)
    }
    
    // Set the ball spin
    func setBallSpin(_ spin: Bool) {
        guard let char = ballSpinChar.characteristic else { return }
        guard isConnected else { return }
        
        let str = String(spin ? "1" : "0")
        let data = Data(str.utf8)
        peripheral.writeValue(data, for: char, type:. withoutResponse)
    }
}
