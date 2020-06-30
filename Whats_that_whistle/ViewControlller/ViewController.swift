//
//  ViewController.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 25/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UITableViewController {
    static var isDirty = true
    var whistles = [Whistle]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if ViewController.isDirty {
            loadWhistles()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "What's the Whistle"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Genres", style: .plain, target: self, action: #selector(selectGenre))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    //MARK: - BUTTON ACTIONS
    @objc func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectGenre() {
        let vc = MyGenresViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - TABLEVIEW DATA SOURCE
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let whistle = whistles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText =  makeAttributedString(title: whistle.genre, subtitle: whistle.comment)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        whistles.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ResultsViewController()
        vc.whistle = whistles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    //MARK: - METHODS
    //Loading data from ICloud
    func loadWhistles() {
        let predicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Whistles", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        //Use query operation when we want only some fields
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["genre" , "comment"]
        operation.resultsLimit = 50
        
        var newWhistles = [Whistle]()
        
        //Pass in a closure that takes a record to the operation object...to handle downloading
        operation.recordFetchedBlock = { record in
            let whistle = Whistle()
            whistle.recordID = record.recordID
            whistle.comment = record["comment"]
            whistle.genre = record["genre"]
            newWhistles.append(whistle)
        }
        
        //Set a closure on the operation object to handle completion
        operation.queryCompletionBlock = { [unowned self ] cursor , error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.configureAlert(title: "Fetch failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)")
                    return
                }
                ViewController.isDirty = false
                self.whistles = newWhistles
                self.tableView.reloadData()
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation) //Adds the created operation to the container to run it.
    }
    
    
    
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttrs : [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .headline),
            .foregroundColor: UIColor.purple
        ]
        let subtitleAttrs: [NSAttributedString.Key: Any]  = [.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        
        
        let titleString = NSMutableAttributedString(string: title, attributes: titleAttrs)
        
        if subtitle.count > 0 {
            let subtitleString = NSMutableAttributedString(string: "\n\(subtitle)", attributes: subtitleAttrs)
            titleString.append(subtitleString)
        }
        
        return titleString
    }
    
    
    
    func configureAlert(title: String! , message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

