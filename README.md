# indoor-navigation
這個是給視障者在陌生的室內環境進行導航時，提供一項可以參考的工具 
本專案硬體適用於ESP32-S之型號、iBeacon與應用iPhone13進行開發 
韌體版本為iOS 18.2, ESP32內建版本為MicroPython 1.23.0

## 本專案使用指南
### 0 iBeacon對應APP下載(若有需要者可以看txt檔)

### 1-1.確認Xcode版本 & Swift版本
Xcode版本是否為16.2 
Xcode 版本可以透過功能列的Xcode -> About Xcode中找到

Swift版本為6.0 
Swift 版本可以在終端機以swift -version這個指令進行查找 

### 1-2.確認Arduino與ESP32版本
Arduino版本為2.3.4 
[Arduino下載網址](<https://www.arduino.cc/en/software>)

ESP32的韌體版本為MicroPython 1.23.0 
[Thonny Python IDE下載](<https://micropython.org/download/esp32/>)
下載Thonny Python IDE完成後，啟動Thonny Python IDE 
1. 下載esptool，路徑如下： 
Tools -> Manage plug-ins -> search esptool -> install 
2. 下載ESP32的韌體，路徑如下： 
Tools -> Options -> interpreter -> Micropython (ESP32) -> select port CP2102 USB to UART Bridge Controller (/dev/ttyUSB0) -> install or update firmware
更新完成後，ESP32韌體即完成
[圖解步驟網址](<https://sites.google.com/site/wenyunotify/05-esp32/05-micropython>)

ESP32的軟體版本為3.1.1
從開發板管理員去尋找ESP32找到Espressif的ESP32，下載3.1.1版本即可
[ESP32版本參考網址](<https://github.com/espressif/arduino-esp32>)

### 2.即可下載本專案

***
## 本專案成效
