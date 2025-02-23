# indoor-navigation
這個是給視障者在陌生的室內環境進行導航時，提供一項可以參考的工具，給iOS APP開發新手學習Xcode介面控制<br> 
本專案硬體適用於ESP32-S之型號、iBeacon與應用iPhone13進行開發<br>
韌體版本為iOS 18.2, ESP32內建版本為MicroPython 1.23.0

## 目錄
-[安裝與版本確認指南](#安裝與版本確認指南)<br>
-[專案成果展示](#專案成果展示)

## 安裝與版本確認指南
### 0 iBeacon對應APP下載(若有需要者可以看txt檔)

### 1-1 確認Xcode版本 & Swift版本
Xcode版本是否為16.2<br>
Xcode 版本可以透過功能列的Xcode -> About Xcode中找到

Swift版本為6.0<br>
Swift 版本可以在終端機以swift -version這個指令進行查找 

### 1-2 確認Arduino與ESP32版本
Arduino版本為2.3.4<br>
[Arduino下載網址，參考資料：Arduino IDE官網](<https://www.arduino.cc/en/software>)

ESP32的韌體版本為MicroPython 1.23.0<br>
[Thonny Python IDE下載，參考資料：Thonny Python官網](<https://micropython.org/download/esp32/>)<br>
下載Thonny Python IDE完成後，啟動Thonny Python IDE<br> 
1. 下載esptool，路徑如下：<br>
Tools -> Manage plug-ins -> search esptool -> install<br> 
2. 下載ESP32的韌體，路徑如下：<br> 
Tools -> Options -> interpreter -> Micropython (ESP32) -> select port CP2102 USB to UART Bridge Controller (/dev/ttyUSB0) -> install or update firmware<br>
更新完成後，ESP32韌體即完成<br>
[圖解步驟網址，參考資料：阿玉教學網](<https://sites.google.com/site/wenyunotify/05-esp32/05-micropython>)<br>

ESP32的軟體版本為3.1.1<br>
從開發板管理員去尋找ESP32找到Espressif的ESP32，下載3.1.1版本即可<br>
[ESP32版本參考網址，參考資料：Github](<https://github.com/espressif/arduino-esp32>)

### 2 即可下載本專案

### 3 相關補充資料
[Xcode介面操作與介紹影片，參考資料：YT ChaoCode](<https://www.youtube.com/watch?v=JQSkZ908zVo>)
***
## 專案成果展示
本專案成果透過設計回饋問卷的題目評估系統可用性。搜集了 14 份使用者回饋問卷(其中三位不熟悉北醫醫資所辦公室環境為前提所進行的導航體驗)。結果顯示，87%的使用者有依照指示順利走到目的地，則 APP 的使用者滿意度為 3.8/5 分。
![image](/手機介面截圖/手機APP介面截圖/首頁.png)



