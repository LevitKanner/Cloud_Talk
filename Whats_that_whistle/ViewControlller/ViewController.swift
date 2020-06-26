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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    @objc func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - TABLEVIEW DATA SOURCE
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let whistle = whistles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText =  makeAttributedString(title: whistle.genre, subtitle: whistle.comments)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    
    
    
    //MARK: - METHODS
    func loadWhistles() {
        
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
}

