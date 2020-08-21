//
//  TasksTableViewController.swift
//  PyLoungeTask
//
//  Created by pylounge on 19.08.2020.
//  Copyright © 2020 pylounge. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

extension NSNotification.Name{
    static let reload = NSNotification.Name("reload")
}

class TasksTableViewController: UITableViewController {

    var tasks = [Task]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController else {
            return
        }

        guard let addTaskVC = navigationController.viewControllers.first as? AddTaskViewController else {
            return
        }

        addTaskVC.saveCompletion = {
            self.loadData()
        }
    }
    
    func loadData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
               let context = appDelegate.persistentContainer.viewContext
               let fetchRequest = Task.fetchRequest() as NSFetchRequest<Task>
               
               let sortDescriptor1 = NSSortDescriptor(key: "descriptionTask", ascending: true)
               let sortDescriptor2 = NSSortDescriptor(key: "dateTime", ascending: true)
               fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
               
               do{
                   tasks = try context.fetch(fetchRequest)
               } catch let error{
                   print("Error: \(error)")
               }
               tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellIdentifier", for: indexPath)
        let task = tasks[indexPath.row]
        
        let description = task.descriptionTask ?? ""
        let period = task.period ?? ""
        print("After: ", period)

        cell.textLabel?.text = description + " Period: " + period
        
        if let date = task.dateTime as Date?{
            cell.detailTextLabel?.text = dateFormatter.string(from: date) + " Period: " + period
        } else {
            cell.detailTextLabel?.text = " "
        }
        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tasks.count > indexPath.row{
            let task = tasks[indexPath.row]
            
            if let identifier = task.taskId{
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(task)
            tasks.remove(at: indexPath.row)
            
            do{
                try context.save()
            } catch let error{
                print("Error: \(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        tableView.reloadData()
    }
    


    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
