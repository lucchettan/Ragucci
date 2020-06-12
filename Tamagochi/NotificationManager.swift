//
//  NotificationManager.swift
//  Tamagochi
//
//  Created by Alessio Petrone on 21/11/2019.
//  Copyright © 2019 Ragu. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate{
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    /**
     Ask permission to send local notifications
     */
    func requestAuthorization(){
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in

            if granted == true && error == nil {
                print("User has granted notifications")
            }
        }
    }
    
    // Check notification permission before schedule notifications
    private func schedule(notification: Notification){
        notificationCenter.getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotification(notification)
            default:
                break // Do nothing
            }
        }
    }
    
    // Schedule
    private func scheduleNotification(_ notification: Notification)
    {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound    = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notification.timeInterval, repeats: false)
            
            let request: UNNotificationRequest
            
            switch notification.id {
                case .hungry:
                    request = UNNotificationRequest(identifier: "hungry", content: content, trigger: trigger)
                case .thirsty:
                    request = UNNotificationRequest(identifier: "thirsty", content: content, trigger: trigger)
            }

            notificationCenter.add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
    }
    
    /**
        Create notification that will be schedule.
     If notifications that will be scheduled have the same id, the system will replace it with the last added
     - Parameters _ notification: Notification that will be scheduled
     */
    func setNotification(_ notification: Notification ){
        schedule(notification: notification)
    }
    
    /**
     Remove notifications scheduled with specific ids
      - Parameters _ notification: Notification that will be scheduled
     */
    func removeScheduledNotifications(_ notificationsIds: [NotificationType]){
        var notif = [String]()
        
        for notification in notificationsIds {
            switch notification {
                
            case .hungry:
                notif.append("hungry")
            case .thirsty:
                notif.append("thirsty")
            }
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notif)
    }
}

struct Notification{
    let id: NotificationType
    let title: String
    let body: String
    let timeInterval: TimeInterval
}

enum NotificationType{
    case hungry
    case thirsty
}
