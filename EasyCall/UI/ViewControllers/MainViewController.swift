//
//  NavigationViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var contactsViewController: ContactsViewController!
    var loginViewController: LoginViewController!
    var loginNavigationController: UINavigationController!
    var contactsNavigationController: UINavigationController!
    
    var isConnected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLoggedIn(notification:)), name: Notification.Name("UserLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLoggedOut(notification:)), name: Notification.Name("UserLoggedOut"), object: nil)
        
        loginViewController = LoginViewController(nibName: nil, bundle: nil)
        loginNavigationController = UINavigationController(rootViewController: loginViewController)
        contactsViewController = ContactsViewController (nibName: nil, bundle: nil)
        contactsNavigationController = UINavigationController(rootViewController: contactsViewController)
        
        self.changeDisplayedController(animated: true)
    }
    
    @objc
    func userDidLoggedIn(notification: NSNotification){
        isConnected = true
        self.changeDisplayedController(animated: true)
    }
    
    @objc
    func userDidLoggedOut(notification: NSNotification){
        isConnected = false
        self.changeDisplayedController(animated: true)
    }
    
    func changeDisplayedController(animated : Bool) {
        if isConnected {
            
            addChild(contactsNavigationController)
            view.addSubview(contactsNavigationController.view)
            contactsNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contactsNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                contactsNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                contactsNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                contactsNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                ])
            contactsNavigationController.didMove(toParent: self)
            contactsNavigationController.view.alpha = 0
            contactsNavigationController.view.isHidden = false
            UIView.animate(withDuration: 1.5) {
                self.contactsNavigationController.view.alpha = 1
            }
            loginNavigationController.view.isHidden = true
        } else {
            
            addChild(loginNavigationController)
            view.addSubview(loginNavigationController.view)
            loginNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loginNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                loginNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                loginNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                loginNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                ])
            loginNavigationController.didMove(toParent: self)
            
            
            loginNavigationController.view.alpha = 0
            loginNavigationController.view.isHidden = false
            UIView.animate(withDuration: 1.5) {
                self.loginNavigationController.view.alpha = 1
            }
            contactsNavigationController.view.isHidden = true
        }
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

