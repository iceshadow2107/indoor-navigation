//
//  save.swift
//  indoor navigation
//
//  Created by Lily Wang on 2025/1/14.
//
import Foundation

struct NavigationLog: Codable {
    let uuid: String
    let timestamp: String
}

class JsonManager {
    private var logs: [NavigationLog] = []
    private let fileName = "NavigationLog.json"
    
    // 新增記錄
    func addLog(uuid: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let newLog = NavigationLog(uuid: uuid, timestamp: timestamp)
        logs.append(newLog)
    }
    
    // 儲存至 JSON 檔案
    func saveToJson() {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let jsonData = try JSONEncoder().encode(logs)
            try jsonData.write(to: fileURL)
            print("導航記錄已儲存至：\(fileURL)")
        } catch {
            print("儲存 JSON 檔案失敗：\(error.localizedDescription)")
        }
    }
    
    // 獲取專案目錄
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

