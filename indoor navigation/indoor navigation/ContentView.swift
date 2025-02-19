//
//  ContentView.swift
//  indoor navigation
//
//  Created by Lily Wang on 2024/9/29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var indoorNavigationManager : IndoorNavigationManager // 設一個全域變數抓class
    @State private var isDetailPageActive1 = false
    @State private var isDetailPageActive2 = false
    @State private var isDetailPageActive3 = false
    @State private var showAlert = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .scaledToFit()
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("想要去哪裡？")
                    .font(.system(size: 48))
                
                // 第一個按鈕：醫資所秘書辦公室
                Button(action: {
                    isDetailPageActive1 = true // 改變狀態觸發導航
                }){
                    Text("醫資所秘書辦公室")
                        .font(.system(size: 48))
                        .padding()
                        .frame(width: 400, height: 150)
                        .background(Color.green.opacity(0.4))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .navigationDestination(isPresented: $isDetailPageActive1) {
                    DetailPage1()
                }
                
                // 第二個按鈕：醫資所所長辦公室
                Button(action: {
                    isDetailPageActive2 = true // 改變狀態觸發導航
                }) {
                    Text("醫資所所長辦公室")
                        .font(.system(size: 48))
                        .padding()
                        .frame(width: 400, height: 150)
                        .background(Color.brown.opacity(0.4))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .navigationDestination(isPresented: $isDetailPageActive2) {
                    DetailPage2()
                }
                
                // 第三個按鈕：邱泓文老師辦公室
                Button(action: {
                    isDetailPageActive3 = true // 改變狀態觸發導航
                }) {
                    Text("邱泓文老師辦公室")
                        .font(.system(size: 48))
                        .padding()
                        .frame(width: 400, height: 150)
                        .background(Color.blue.opacity(0.4))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .navigationDestination(isPresented: $isDetailPageActive3) {
                    DetailPage3()
                }
            }
            .padding()
        }
    }
}
    
    
struct DetailPage1: View {
    @EnvironmentObject var indoorNavigationManager : IndoorNavigationManager // 設一個全域變數抓class
    var body: some View {
        NavigationStack {
            VStack{
                Text("開始導航至醫資所秘書辦公室")
                    .font(.system(size: 48))
                    .padding()
                if indoorNavigationManager.isNavigationCompleted {
                    Text("導航完成！")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("導航進行中...")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .padding()
                }
                // 導航到子分頁
                NavigationLink(destination: ImagePageView(imageName: "使用者問卷回饋")) {
                    Text("意見回饋")
                        .font(.system(size: 48))
                        .padding()
                        .frame(width: 400, height: 150)
                        .background(Color.purple.opacity(0.5))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("導航頁面")
        }
    }
}

struct DetailPage2: View {
    @EnvironmentObject var indoorNavigationManager : IndoorNavigationManager // 設一個全域變數抓class
    var body: some View {
        NavigationStack {
            VStack{
                Text("開始導航至醫資所所長辦公室")
                    .font(.system(size: 48))
                    .padding()
                if indoorNavigationManager.isNavigationCompleted {
                    Text("導航完成！")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("導航進行中...")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .padding()
                }
            // 導航到子分頁
                NavigationLink(destination: ImagePageView(imageName: "使用者問卷回饋")) {
                    Text("意見回饋")
                        .font(.system(size: 48))
                        .padding()
                        .frame(width: 400, height: 150)
                        .background(Color.purple.opacity(0.5))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("導航頁面")
        }
    }
}
    
struct DetailPage3: View {
    @EnvironmentObject var indoorNavigationManager : IndoorNavigationManager // 設一個全域變數抓class
    var body: some View {
        NavigationStack {
            VStack{
                Text("開始導航至邱泓文老師辦公室")
                    .font(.system(size: 48))
                    .padding()
                if indoorNavigationManager.isNavigationCompleted {
                    Text("導航完成！")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("導航進行中...")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .padding()
                }
                // 導航到子分頁
                NavigationLink(destination: ImagePageView(imageName: "使用者問卷回饋")) {
                    Text("意見回饋")
                        .font(.system(size: 48))
                        .padding()
                        .frame(width: 400, height: 150)
                        .background(Color.purple.opacity(0.5))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("導航頁面")
        }
    }
}

struct ImagePageView: View {
    let imageName: String // 接收圖片名稱
    
    var body: some View {
        VStack {
            Image(imageName) // 顯示圖片
                .resizable() // 讓圖片可調整大小
                .scaledToFit() // 按比例縮放
                .frame(width: 300, height: 300) // 設定圖片大小
                .cornerRadius(16) // 圓角效果
                .shadow(radius: 10) // 加入陰影

            Text("使用者問卷回饋")
                .font(.system(size: 48))
                .padding()
        }
        .navigationTitle("意見回饋頁面")
    }
}

#Preview{
    ContentView()
        .environmentObject(IndoorNavigationManager())
}
