#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <WiFi.h> // 包含 WiFi 函式庫

#ifndef ESP_MAC_WIFI_STA
#define ESP_MAC_WIFI_STA 0 // 0 代表 Wi-Fi STA 模式的 MAC
#endif

#define BUZZER_PIN 27   // 蜂鳴器接到 GPIO 27
#define PWM_FREQ 1000 // PWM 頻率（Hz），適合有源蜂鳴器的頻率
#define PWM_RESOLUTION 16 // PWM 分辨率（8 位，範圍 0-255）
#define SCAN_TIME 5     // 掃描時間（秒）
#define RSSI_THRESHOLD -70 // 信號強度閾值，用於指引範圍

BLEScan *pBLEScan;                  // BLE 掃描對象
bool targetFound = false;           // 是否找到目標設備
const size_t maxSize = 10;          // RSSI 緩存大小
int rssiBuffer[maxSize];
size_t rssiIndex = 0;
// 自定義 UUID
#define CHARACTERISTIC_UUID "20a982e4-1dd2-11b2-8000-f008d1f247c0"


// 添加 RSSI 到濾波器
void addRSSIToBuffer(int rssi) {
    rssiBuffer[rssiIndex % maxSize] = rssi;
    rssiIndex++;
}

// 滑動平均濾波函式
float calculateAverageRSSI() {
    size_t count = (rssiIndex < maxSize) ? rssiIndex : maxSize;
    if (count == 0) return 0;
    int sum = 0;
    for (size_t i = 0; i < count; i++) {
        sum += rssiBuffer[i];
    }
    return static_cast<float>(sum) / count;
}

// 掃描回呼函數
class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
        if (advertisedDevice.getName() == "MBeacon") { // 替換為目標設備名稱
            targetFound = true;
            int rssi = advertisedDevice.getRSSI();
            Serial.printf("掃描到目標設備，RSSI: %d\n", rssi);
            addRSSIToBuffer(rssi); // 添加 RSSI 值到濾波器
        }
    }
};

// 播放蜂鳴器聲音
void playBuzzerTone(int volume, int durationMs) {
    ledcWrite(BUZZER_PIN, volume); // 設定占空比（音量）
    delay(durationMs);              // 播放指定時間
    ledcWrite(BUZZER_PIN, 0);      // 關閉聲音
    delay(100);                     // 停頓一段時間避免連續聲音
}
// 基於 MAC 地址生成 UUID
// String generateUUID() {
//     uint8_t mac[6];
//     WiFi.macAddress(mac); // 使用 Arduino 函式取得 MAC 地址
//     char uuid[37]; // UUID 的標準格式為 8-4-4-4-12，共 36 字符 + 空終止符
//     sprintf(uuid, "%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
//             mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], 
//             mac[0] ^ mac[3], mac[1] ^ mac[4], mac[2] ^ mac[5],
//             mac[0] & 0xFF, mac[1] & 0xFF, mac[2] & 0xFF,
//             mac[3] | 0xF0, mac[4] | 0x0F, mac[5] ^ 0xAA);
//     return String(uuid);
// }

void setup() {
    Serial.begin(115200);
    ledcAttach(BUZZER_PIN, PWM_FREQ, PWM_RESOLUTION);

    // 初始化 BLE 掃描
    BLEDevice::init("ESP32_BLE_Scanner");
    pBLEScan = BLEDevice::getScan();
    pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
    pBLEScan->setActiveScan(true);
    pBLEScan->setInterval(100);
    pBLEScan->setWindow(99);

    Serial.println("設備的自定義 UUID: ");
    Serial.println(CHARACTERISTIC_UUID);
}
void loop() {
    Serial.println(F("開始掃描..."));
    targetFound = false; // 重置目標找到狀態

    BLEScanResults* results = pBLEScan->start(SCAN_TIME, false);
    Serial.printf("掃描完成，共發現設備數量: %d\n", results->getCount());

    if (targetFound) {
        // float averageRSSI = calculateAverageRSSI();
        // Serial.printf("濾波後的平均 RSSI: %.2f\n", averageRSSI);

        // if (averageRSSI > RSSI_THRESHOLD) {
        Serial.println(F("目標設備在附近，靠近它！"));
        for (int i = 0; i < 3; i++) { // 播放提示音
            playBuzzerTone(255, 500);
        }
    } else {
        Serial.println(F("目標設備距離較遠，繼續前進..."));
}
    // } else {
    //     Serial.println(F("未找到目標 Beacon。播放警告音..."));
    //     for (int j = 0; j < 2; j++) {
    //         playBuzzerTone(128, 500);
    //     }
    // }

    pBLEScan->clearResults(); // 清空掃描結果釋放記憶體
    delay(2000);              // 等待一段時間後再次掃描
}
