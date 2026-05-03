# ROSIE Control Panel
<p align="center">
    <img src="Docs/Assets/ROSIE_logo.png" width="200" alt="Project Logo">
</p>
An iOS app used to control the ROSIE tennis ball launcher via Bluetooth Low Energy (BLE).

## Features
- Control motor spin
- Toggle ball spin
- Monitor motor RPM
- Voice control feature

## Setup
## Prerequisites
- iOS 14.0+
- Xcode 14.0+
- Bluetooth enabled
- ROSIE hardware running the [ROSIE](https://github.com/KennyC3200/ROSIE) program

### Installation
1. Clone the repository
```
git clone --recursive https://github.com/KennyC3200/ROSIE-Control-Panel
```
2. Open `ROSIE.xcodeproj` in Xcode
3. Select your target device
4. Build and run

## BLE Interface
The BLE connects to the ESP32 onboard the ROSIE via the following UUIDs:
| Characteristic | UUID | Description |
|----------------|------|-------------|
| motor_speed_percent | 7e77c276-... | Read or write motor speed as a percent of the max speed ("0" to "100") |
| motor_1_RPM | 76bd9c05-... | Read motor 1 RPM |
| motor_2_RPM | d7bc8ea0-... | Read motor 2 RPM |
| ball_spin | 775c47cf-... | Read/write ball spin ("1"/"0") |
