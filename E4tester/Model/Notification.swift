//
//  Notification.swift
//  E4tester
//
//  Created by Waley Zheng on 9/7/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

func askNotificationPermission() {
    // ask permission
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        
        if let error = error {
            print(error.localizedDescription)
        }
    }
}

func scheduleNotification(content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
    // Create the request
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
           print(error?.localizedDescription ?? "")
       }
    }
}

func registerRegularNotification() {
    // schedule regular notification
    let content = UNMutableNotificationContent()
    content.title = "DPM Wearable"
    content.body = "Check out your crew's fatigue levels!"
    
    // Configure the recurring date.
    var dateComponents = DateComponents()
    dateComponents.hour = 12
    dateComponents.minute = 00
       
    // Create the trigger as a repeating event.
    let trigger1 = UNCalendarNotificationTrigger(
             dateMatching: dateComponents, repeats: true)
    scheduleNotification(content: content, trigger: trigger1)
    
    // Configure the recurring date.
    dateComponents.hour = 15
    dateComponents.minute = 00
       
    // Create the trigger as a repeating event.
    let trigger2 = UNCalendarNotificationTrigger(
             dateMatching: dateComponents, repeats: true)
    scheduleNotification(content: content, trigger: trigger2)
}

func cancelRegularNotification() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
}


func registerPeerNotification(first_name: String) {
    // schedule peer notification
    let content = UNMutableNotificationContent()
    content.title = "DPM Wearable"
    content.body = "\(first_name)'s fatigue level is high!"
       
    // Create the trigger as a repeating event.
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 1, repeats: false)
    scheduleNotification(content: content, trigger: trigger)
    print("done...")
}
