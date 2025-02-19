//
//  CoreBluetooth.swift
//  indoor navigation
//
//  Created by Lily Wang on 2024/9/30.
//

import CoreBluetooth
import CoreLocation
import AVFoundation
import SwiftUI
import Foundation

struct ESP32Device: Identifiable {
    let id: UUID = UUID() // 用於 SwiftUI 的唯一標識
    let name: String      // ESP32 名稱
    let uuid: String      // ESP32 的 UUID 或 MAC 地址
    var rssi: Int         // 信號強度
    var isConnected: Bool // 是否連線
    let peripheral: CBPeripheral    // CoreBluetooth 的 CBPeripheral 對象
}

class IndoorNavigationManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    // SwiftUI 狀態
    @Published var isNavigationCompleted = false
    @Published var isConnected: Bool = false
    @Published var beaconDetected: Bool = false
    @Published var estimatedDistance: Double = 0.0 // 預估距離
    @Published var esp32Devices: [ESP32Device] = []
    
    // CoreBluetooth 相關屬性
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private let targetServiceUUID = CBUUID(string: "180D") // 替換為 ESP32 提供的服務 UUID
    
    // CoreLocation 相關屬性
    private var locationManager = CLLocationManager()
    private let beaconUUID = UUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825")!
    private var beaconRegion: CLBeaconRegion!
    private var detectedUUIDs: Set<String> = []
    private let jsonManager = JsonManager()
    
    // 音效播放
    private var audioPlayer = AVAudioPlayer()
    
    // RSSI 濾波器參數
    private var rssiBuffer: [NSNumber] = [] // 儲存最近的 RSSI 值
    private let maxBufferSize = 10          // 滑動窗口大小
    private let txPower = -59               // Tx Power，假設為 -59 dBm（根據設備調整）
    private let environmentFactor = 2.0     // 環境損耗指數（2~3）
    
    override init() {
        super.init()
        
        // 初始化 CoreBluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // 初始化 CoreLocation
        locationManager = CLLocationManager()
        locationManager.delegate = self
        beaconRegion = CLBeaconRegion(uuid: beaconUUID, identifier: "MBeacon")
    }
    
    // 添加 RSSI 到緩衝區並進行濾波
    private func addRSSIToBuffer(_ rssi: NSNumber) {
        if rssiBuffer.count >= maxBufferSize {
            rssiBuffer.removeFirst() // 移除最舊的值
        }
        rssiBuffer.append(rssi)
    }

    // 計算滑動平均 RSSI
    private func calculateAverageRSSI() -> Double? {
        guard !rssiBuffer.isEmpty else { return nil }
        let sum = rssiBuffer.reduce(0) { $0 + $1.doubleValue }
        return sum / Double(rssiBuffer.count)
    }

    // 根據平均 RSSI 計算距離
    private func calculateDistance(from rssi: Double) -> Double {
        return pow(10.0, (Double(txPower) - rssi) / (10 * environmentFactor))
    }
    
    // 開始導航
    func startNavigation() {
        locationManager.requestAlwaysAuthorization()
        let targetUUIDs = [
            UUID(uuidString: "34be3cac-1dd2-11b2-8000-943cc60fa5f8")!,
            UUID(uuidString: "2816fa02-1dd2-11b2-8000-f008d1f2b518")!,
            UUID(uuidString: "2a0ec7ab-1dd2-11b2-8000-943cc6114b6c")!,
            UUID(uuidString: "1ee9bc08-1dd2-11b2-8000-943cc610b82c")!,
            UUID(uuidString: "250482c8-1dd2-11b2-8000-943cc60f01dc")!,
            UUID(uuidString: "1fea80d2-1dd2-11b2-8000-f008d1f3ae90")!,
            UUID(uuidString: "2ed2330b-1dd2-11b2-8000-943cc611f100")!,
            UUID(uuidString: "36e187bd-1dd2-11b2-8000-943cc60dd54c")!
        ]

        for uuid in targetUUIDs {
            let region = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(satisfying: region.beaconIdentityConstraint)
        }
    }
    
    // 停止導航
    func stopNavigation() {
        centralManager.stopScan()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        print("停止導航")
    }
    
    // MARK: - CoreBluetooth
    private func startBluetoothScanning() {
        if centralManager.state == .poweredOn {
            esp32Devices.removeAll() // 清空設備記錄
            print("開始掃描 ESP32 設備...")
            centralManager.scanForPeripherals(withServices: [targetServiceUUID])
        } else {
            print("Bluetooth 未開啟")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("藍牙已啟用，可以掃描")
        } else {
            print("藍牙未啟用")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name else { return }
        centralManager.stopScan()
        print("發現 ESP32 設備，嘗試連接：\(peripheral.name ?? "Unknown")")
        centralManager.connect(peripheral, options: nil)
        targetPeripheral = peripheral
        // 避免重複記錄同一設備
        if !esp32Devices.contains(where: { $0.uuid == peripheral.identifier.uuidString }) {
            let newDevice = ESP32Device(
                name: name,
                uuid: peripheral.identifier.uuidString,
                rssi: RSSI.intValue,
                isConnected: false,
                peripheral: peripheral // 引用儲存設備
            )

            // 僅記錄最多 10 個設備
            if esp32Devices.count >= 10 {
                esp32Devices.removeFirst() // 刪除最早記錄的設備
            }
            
            // 添加 RSSI 到濾波器並更新距離
            addRSSIToBuffer(RSSI)
            if let averageRSSI = calculateAverageRSSI() {
                estimatedDistance = calculateDistance(from: averageRSSI)
                print("目標設備的預估距離：\(estimatedDistance) 公尺")
            }
            esp32Devices.append(newDevice)
            print("發現設備：\(name)，UUID：\(peripheral.identifier.uuidString)，RSSI：\(RSSI.intValue)")
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("成功連接到設備：\(peripheral.name ?? "Unknown")")
        if let index = esp32Devices.firstIndex(where: { $0.uuid == peripheral.identifier.uuidString }) {
            esp32Devices[index].isConnected = true
            let uuidString = peripheral.identifier.uuidString
            sendCommandToESP32(peripheral, command: "PlayBeep", uuid: uuidString)
        }
    }
    
    func connectToDevice(uuid: String) {
        guard let targetDevice = esp32Devices.first(where: { $0.uuid == uuid }) else { return }
        centralManager.connect(targetDevice.peripheral, options: nil)
    }
    
    private func sendCommandToESP32(_ peripheral: CBPeripheral, command: String, uuid: String) {
        _ = CBUUID(string: "2A56")
        peripheral.discoverServices([targetServiceUUID])
        peripheral.delegate = self
        
        // 儲存到 JSON
        jsonManager.addLog(uuid: uuid)
        jsonManager.saveToJson()
        
        // 發送指令並播放蜂鳴器音效
        print("已向 UUID \(uuid) 的設備發送指令：\(command)")
    }

    
    func determineDirection(to rssi: Int) -> String {
        if rssi > -50 {
            return "目標在正前方，請繼續直走。"
        } else if rssi < -70 {
            return "目標在左方，請左轉。"
        } else {
            return "目標在右方，請右轉。"
        }
    }

    func provideFeedback(isCorrect: Bool) {
        if isCorrect {
            print("導航正確，播放提示音")
        } else {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            print("導航錯誤，產生震動")
        }
    }

    
    // MARK: - CoreLocation
    func startBeaconScanning() {
        locationManager.requestAlwaysAuthorization()
        let beaconUUIDs = [
            UUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825")!
        ]
                
        for uuid in beaconUUIDs {
            let region = CLBeaconRegion(uuid: uuid, identifier: uuid.uuidString)
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(satisfying: region.beaconIdentityConstraint)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying constraint: CLBeaconIdentityConstraint) {
        for beacon in beacons {
            let uuidString = beacon.uuid.uuidString
            guard !detectedUUIDs.contains(uuidString) else { continue } // 避免重複操作
                    
            detectedUUIDs.insert(uuidString)
            print("發現 Beacon：\(uuidString)")
            
            startBluetoothScanning()
            if uuidString == "2816fa02-1dd2-11b2-8000-f008d1f2b518" {
                isNavigationCompleted = true
            }
        }
    }
    
    // MARK: - 音效播放
    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("音效檔案 \(soundName) 不存在")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("無法播放音效 \(soundName)：\(error.localizedDescription)")
        }
    }
}

// MARK: - BeaconTrackingViewController
class BeaconTrackingViewController: UIViewController {
    
    let indoorManager = IndoorNavigationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indoorManager.startNavigation()
    }
}
