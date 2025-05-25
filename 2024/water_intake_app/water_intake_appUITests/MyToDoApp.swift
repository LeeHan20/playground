//
//  MyToDoApp.swift
//  
//
//  Created by 이한 on 5/3/25.
//

import Foundation
import SwiftUI

@main
struct MyToDoApp: App {
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: viewModel)
        }
    }
}
