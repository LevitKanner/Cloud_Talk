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
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder{
            comment.text = ""
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardValue.cgRectValue
        
        let keyboardEndFrame = view.convert(keyboardFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            comment.contentInset = .zero
        }else {
            comment.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        comment.scrollIndicatorInsets = comment.contentInset
        
        let selectRange = comment.selectedRange
        comment.scrollRangeToVisible(selectRange)
    }
    
}
