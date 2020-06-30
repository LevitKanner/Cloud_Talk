//
//  MyGenresViewController.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 30/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresViewController: UITableViewController {
    var myGenres: [String]!
    
    
    //MARK: - VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        if let savedGenres = defaults.object(forKey: "Genres") as? [String] {
            myGenres = savedGenres
        }else{
            myGenres = [ ]
        }
        
        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    //MARK: - BUTTON ACTIONS
    //Create subscription to icloud
    @objc func saveTapped() {
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "Genres")
        
        let database = CKContainer.default().publicCloudDatabase
        
        database.fetchAllSubscriptions {[unowned self] (subscriptions, error) in

            guard error == nil else {
                DispatchQueue.main.async {
                    self.configureAlert(title: "An Error occurred" , message: error!.localizedDescription)
                }
                return
            }
            
            guard let subscriptions = subscriptions else {return }
            
            //Remove all existing subscriptions
            for subscription in subscriptions {
                database.delete(withSubscriptionID: subscription.subscriptionID) { str, error in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.configureAlert(title: "An Error occured", message: error!.localizedDescription)
                        }
                    }
                }
            }
            
            //more to come
            for genre in self.myGenres {
                let predicate = NSPredicate(format: "genre == %@", genre)
                let subscription = CKQuerySubscription(recordType: "Whistles", predicate: predicate, options: .firesOnRecordCreation)
                
                let notification = CKSubscription.NotificationInfo()
                notification.alertBody = "There's a new whistle in the \(genre) genre"
                notification.soundName = "default"
                
                subscription.notificationInfo = notification
                
                database.save(subscription) { (subscription, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.configureAlert(title: "An Error occurred" , message: error.localizedDescription)
                        }
                        
                    }
                }
            }
            
            
        }
    }
    
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SelectGenreViewController.genres.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = SelectGenreViewController.genres[indexPath.row]
        cell.textLabel?.text = genre
        
        if myGenres.contains(genre){
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let selectedGenre = SelectGenreViewController.genres[indexPath.row]
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            }else {
                cell.accessoryType = .none
                
                if let indexOfGenre = myGenres.firstIndex(of: selectedGenre){
                    myGenres.remove(at: indexOfGenre)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func configureAlert(title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
}
