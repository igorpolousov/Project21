//
//  ViewController.swift
//  Project21
//  Day 72-73
//  Created by Igor Polousov on 24.11.2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    // Задание 2
    var timeInterval: Double = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Добавили две кнопки с вызовом функций
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
    }

    // Запрос пользователю на разрешение уведомлений
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        // Типы уведомлений которые будут отправляться пользователю указаны в массиве
        // Пользователь может отказать в авторизации локальных уведомлений потому что он не знает что ему будет отправляться. Для этого делается так же запрос на .provisional notifications. Это даёт возможность послать пробное уведомление пользователю, если он разрешит его оставить, то будет авторизация на остальные уведомления
        center.requestAuthorization(options: [.alert, .badge, .sound, .provisional]) {
            granted, error in
            
            if granted {
                print("Yay")
            } else {
                print("D'oh")
            }
        }
    }
    
    // Планирование уведомления
    @objc func scheduleLocal() {
        registerCategories()
 
        let center = UNUserNotificationCenter.current()
        // Удалили все ожидающие ранее созданные уведомления
        center.removeAllPendingNotificationRequests()
        
        // Что будет содержать уведомление
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "Early bird catches the worm, but  the second mouse gets the cheese"
        // Тип уведомления
        content.categoryIdentifier = "Alarm"
        // Информация котороя сопуствует данному уведомлению
        content.userInfo = ["customData": "fizzbuzz"]
        // Звук уведомления
        content.sound = .default
        
        // Установка времени и даты
        var dateComponents = DateComponents()
        dateComponents.hour = 16
        dateComponents.minute = 59
        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Условие которое запустит другое условие через установленный промежуток времени
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        // Запрос на добавление в расписание уведомления с определенным контентом и с определенным временем запуска
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // Добавили запрос в центр уведомлений
        center.add(request)
    }
    
    // Какие будут показаны варианты действий с уведомлением
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        // Само уведомление будет предоставлять возможные действия, для этого так же добавлен протокол
        center.delegate = self
        
        // Показать на переднем плане при выборе show
        let show = UNNotificationAction(identifier: "show", title: "Tell me more ...", options: .foreground)
        
        let delay = UNNotificationAction(identifier: "delay", title: "Delay for 24 hours", options: .foreground)
        // Добавили действие show к notification category при появлении уведомления с ID Alarm
        let category = UNNotificationCategory(identifier: "Alarm", actions: [show, delay], intentIdentifiers: [], options: [])

        // Добавили категорию в центр уведомлений
        center.setNotificationCategories([category])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Получаемая из сообщения информация
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom Data received: \(customData)")
            
            
            // Выбор действия пользователя
            switch response.actionIdentifier {
                // Если пользователь разблокировал устройство
            case UNNotificationDefaultActionIdentifier:
                // Задание 1
              urWelcome(title: "Swipe", massage: "User chose to unlock device")
                // Если пользователь выбрал действие show
            case "show":
                // Задание 1
                urWelcome(title: "View info", massage: "User chose to see more")
                // Задание 2
            case "delay":
                timeInterval = 3600*24
                scheduleLocal()
                urWelcome(title: "Delay 24 hours", massage: "User chose to 24 hours delay")
            default:
                break
            }
        }
        // Обязательно вызывается когда все действия сделаны
        completionHandler()
    }
    // Задание 1
    func urWelcome(title: String, massage: String) {
        let ac = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(ac, animated: true)
    }
    
}


