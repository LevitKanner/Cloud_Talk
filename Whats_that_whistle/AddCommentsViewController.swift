//
//  AddCommentsViewController.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 25/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit

class AddCommentsViewController: UIViewController, UITextViewDelegate {
    var genre: String!
    var comment: UITextView!
    let placeholder = "If you have any additional comments that might help identify your tune, enter them here."
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        comment = UITextView()
        comment.translatesAutoresizingMaskIntoConstraints = false
        comment.delegate = self
        comment.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(comment)
        
        NSLayoutConstraint.activate([
            comment.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            comment.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            comment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            comment.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comment.text = placeholder
        comment.font = UIFont.preferredFont(forTextStyle: .subheadline)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
    }
    
    @objc func submitTapped() {
        let vc = SubmitViewController()
        vc.genre = genre
        
        if comment.text == placeholder {
            vc.comment = ""
        } else {
            vc.comment = comment.text
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder{
            comment.text = ""
        }
    }
    
    
}
