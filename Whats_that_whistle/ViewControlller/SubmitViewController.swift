//
//  SubmitViewController.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 25/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit
import CloudKit

class SubmitViewController: UIViewController {
    var genre: String!
    var comment: String!
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        
        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting…"
        status.textColor = UIColor.white
        status.font = UIFont.preferredFont(forTextStyle: .title1)
        status.numberOfLines = 0
        status.textAlignment = .center
        
        spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doSubmission()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "You're all set!"
        navigationItem.hidesBackButton = true
        
    }
    
    
    
    //MARK: - METHODS
    func doSubmission(){
        //First part; creates a record and sets its data
        let whistleRecord = CKRecord(recordType: "Whistles")
        whistleRecord["genre"] = genre as CKRecordValue
        whistleRecord["comment"] = comment as CKRecordValue
        
        let audioURL = RecordWhistleViewController.getWhistleUrl()
        let whistleAsset = CKAsset(fileURL: audioURL)
        whistleRecord["audio"] = whistleAsset
        
        //Second part; handles saving data to icloud
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] (record, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    //Update UI here...
                    self.status.text = "Error: \(error!.localizedDescription)"
                    self.spinner.stopAnimating()
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
                    return
                }
                
                //If there's no error
                self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                self.status.text = "Done!"
                self.spinner.stopAnimating()
                
                ViewController.isDirty = true
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
            }
            
            
        }
        
    }
    
    @objc func doneTapped() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
}

