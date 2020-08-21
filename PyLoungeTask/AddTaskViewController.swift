//
//  ViewController.swift
//  PyLoungeTask
//
//  Created by pylounge on 18.08.2020.
//  Copyright © 2020 pylounge. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var taskdatePicker: UIDatePicker!
    @IBOutlet weak var periodSegment: UISegmentedControl!
    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var periodSwitcher: UISwitch!
    @IBOutlet weak var periodStack: UIStackView!
    var saveCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        periodStack.isHidden = true
    }
    
    @IBAction func saveDidPressed(_ sender: UIBarButtonItem) {
        let description = descriptionTextField.text ?? ""
        let periodText = periodTextField.text ?? ""
        let taskDate = taskdatePicker.date
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTask = Task(context: context)
        newTask.descriptionTask = description
        newTask.dateTime = taskDate
        newTask.taskId = UUID().uuidString
        
        if periodSwitcher.isOn{
            if (0...3).contains(periodSegment.selectedSegmentIndex) {
                newTask.period = periodSegment.titleForSegment(at: periodSegment.selectedSegmentIndex)!
            } else {
                if let minutes = Int(periodText){
                    newTask.period = periodText
                } else {
                    newTask.period = nil
                }
            }
        } else {
            newTask.period = nil
        }
        
        do{
            try context.save()
            let message = "\(String(describing: newTask.descriptionTask)) !!!"
            makeNotify(msg: message, task: newTask)
        } catch let error{
            print("Error: \(error)")
        }
        dismiss(animated: true, completion: saveCompletion)
    }
    
    func makeNotify(msg: String, task: Task){
        let content = UNMutableNotificationContent()
        content.body = msg
        content.sound = UNNotificationSound.default
        
        var dateParts: Set<Calendar.Component> = [.year, .month, .weekday, .day, .hour, .second]
        
        var dateComponents = Calendar.current.dateComponents(dateParts, from: task.dateTime!)
        
        var trigger: UNNotificationTrigger?
        
        if let periodRepeat = task.period{
            if let time = Double(periodRepeat){
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: true)
            } else {
                switch periodRepeat{
                case "Year":
                    dateParts.remove(.year)
                case "Month":
                    dateParts.remove(.month)
                case "Week":
                    dateParts.remove(.weekday)
                case "Day":
                    dateParts.remove(.day)
                default: break
                }
                dateComponents = Calendar.current.dateComponents(dateParts, from: task.dateTime!)
                
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            }
        } else {
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }
        
        if let identifier = task.taskId {
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: nil)
        }
    }
    
    @IBAction func periodDidSwitched(_ sender: UISwitch) {
        periodStack.isHidden = !periodStack.isHidden
        
    }
    
    @IBAction func cancelDidPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

