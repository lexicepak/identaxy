//
//  SignInVC.swift
//  identaxy
//
//  Created by Amir Mostafavi on 10/7/19.
//  Copyright © 2019 amir. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInVC: IdentaxyHeader, UITextFieldDelegate {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var emailAddressTextField: IdentaxyTextField!
    @IBOutlet weak var passwordTextField: IdentaxyTextField!
    @IBOutlet weak var loginButton: RoundedCornerButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var loginButtonBottomAnchorConstraint: NSLayoutConstraint!
    var loginButtonInitialY: CGFloat!
    var loginButtonAboveKeyboardY: CGFloat!
    
    var forgotButtonBottomAnchorConstraint: NSLayoutConstraint!
    var forgotButtonInitialY: CGFloat!
    var forgotButtonAboveKeyboardY: CGFloat!
    
    var lock: Bool = false
    var database: DatabaseReference!

    override func loadView() {
        super.loadView()
        activateintialConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setColorMode()
        // Do any additional setup after loading the view.
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
        database = Database.database().reference()

        emailAddressTextField.autocorrectionType = .no
        emailAddressTextField.setPlaceholder(placeholder: "Email address")
        passwordTextField.autocorrectionType = .no
        passwordTextField.setPlaceholder(placeholder: "Password")
        
        emailAddressTextField.textContentType = .oneTimeCode
        passwordTextField.textContentType = .oneTimeCode
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillchange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillchange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillchange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        emailAddressTextField.becomeFirstResponder()
    }
    
    deinit {
        // Stop listening for keyboard events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Logic
    @IBAction func loginButtonPressed(_ sender: Any) {
        login()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            passwordTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            login()
        }
        return false
    }
    
    func login() {
        let alertService = AlertService()
        if let emailAddress = emailAddressTextField.text, let password = passwordTextField.text {
            if (emailAddress == "" || password == "") {
                print("ALERT!!!")
                let alertVC = alertService.alert(title: "Error", message: "Unable to log in with provided credentials.", button: "Dismiss")
                present(alertVC, animated: true, completion: nil)
            } else {
                Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) { authResult, error in
                    if(error != nil) {
                        let alertVC = alertService.alert(title: "Error", message: "Unable to log in with provided credentials.", button: "Dismiss")
                        self.present(alertVC, animated: true, completion: nil)
                    } else {
                        let uid = Auth.auth().currentUser?.uid
                        self.database.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                              let value = snapshot.value as? NSDictionary
                              let firstName = value?["first_name"] as? String ?? ""
                              let lastName = value?["last_name"] as? String ?? ""
                         
                              UserDefaults.standard.set(firstName, forKey: "firstName")
                              UserDefaults.standard.set(lastName, forKey: "lastName")
                                
                              self.createSpinnerView()
                              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.showSwipeVCWithLeftToRightTransition(swipeVCId: "Swipe-Screen")
                              }
                        })
                    }
                }
            }
        } else {
            print("ALERT!!!")
            let alertVC = alertService.alert(title: "Error", message: "Unable to log in with provided credentials.", button: "Dismiss")
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - UI Methods
    func showSwipeVCWithLeftToRightTransition(swipeVCId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: swipeVCId) as! SwipingNewVC
        
        let rightToLeft = CATransition()
        rightToLeft.duration = 0.5
        rightToLeft.type = CATransitionType.push
        rightToLeft.subtype = CATransitionSubtype.fromRight
        rightToLeft.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(rightToLeft, forKey: kCATransition)
        
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false, completion: nil)
    }
    
    func activateintialConstraints() {
        // setting constraints manually in code. Deacrtivate storyboard stuff.
        logo.translatesAutoresizingMaskIntoConstraints = false
        emailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginButtonBottomAnchorConstraint = loginButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        forgotButtonBottomAnchorConstraint = forgotPasswordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            // MARK: Logo constraints
            logo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            logo.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 90),
            logo.widthAnchor.constraint(equalToConstant: 115),
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor, multiplier: 66/115),
            
            // MARK: Email textfield constraints
            emailAddressTextField.topAnchor.constraint(greaterThanOrEqualTo: logo.bottomAnchor, constant: 40),
            emailAddressTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -45),
            emailAddressTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 45),
            
            // MARK: - Password textfield constraints
            passwordTextField.topAnchor.constraint(lessThanOrEqualTo: emailAddressTextField.bottomAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -45),
            passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 45),
            
            // MARK: Login button constraints
            loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loginButton.widthAnchor.constraint(lessThanOrEqualToConstant: 394),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            loginButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            
            // MARK: Forgot password button constraints
            forgotPasswordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        loginButtonBottomAnchorConstraint.isActive = true
        forgotButtonBottomAnchorConstraint.isActive = true
        loginButtonInitialY = loginButton.frame.origin.y
        forgotButtonInitialY = forgotPasswordButton.frame.origin.y
    }
    
    
    // MARK: moving buttons above keyboard
    @objc func keyboardWillchange(notification: NSNotification) {
        let currentButtonFrame = loginButton.frame
        print("keyboard will show \(notification.name.rawValue)")
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            loginButton.frame.origin.y = currentButtonFrame.origin.y
            return
        }
        if (notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillChangeFrameNotification) {
            if (lock) {
                return
            }
            lock = true
            // move up
            if let loginButtonBottomAnchorConstraint = loginButtonBottomAnchorConstraint,
                let forgotButtonBottomAnchorConstraint = forgotButtonBottomAnchorConstraint {
                if let loginButtonAboveKeyboardY = loginButtonAboveKeyboardY, let forgotButtonAboveKeyboardY = forgotButtonAboveKeyboardY {
                    loginButton.frame.origin.y = loginButtonAboveKeyboardY
                    forgotPasswordButton.frame.origin.y = forgotButtonAboveKeyboardY
                }
                loginButtonBottomAnchorConstraint.isActive = false
                forgotButtonBottomAnchorConstraint.isActive = false
            }
            loginButtonBottomAnchorConstraint = loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:
                -keyboardRect.height - 50)
            forgotButtonBottomAnchorConstraint = forgotPasswordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardRect.height - 10)
            loginButtonBottomAnchorConstraint.isActive = true
            forgotButtonBottomAnchorConstraint.isActive = true
            if (notification.name == UIResponder.keyboardWillShowNotification) {
                loginButtonAboveKeyboardY = loginButton.frame.origin.y
                forgotButtonAboveKeyboardY = forgotPasswordButton.frame.origin.y
            }
        } else {
            lock = false
            if let loginButtonBottomAnchorConstraint = loginButtonBottomAnchorConstraint, let forgotButtonBottomAnchorConstraint = forgotButtonBottomAnchorConstraint {
                loginButton.frame.origin.y = loginButtonInitialY
                forgotPasswordButton.frame.origin.y = forgotButtonInitialY
                loginButtonBottomAnchorConstraint.isActive = false
                forgotButtonBottomAnchorConstraint.isActive = false
            }
            loginButtonBottomAnchorConstraint = loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
            forgotButtonBottomAnchorConstraint = forgotPasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            loginButtonBottomAnchorConstraint.isActive = true
            forgotButtonBottomAnchorConstraint.isActive = true
        }
    }
    
    // MARK: loading indicator
    func createSpinnerView() {
        let child = SpinnerViewController()
        DispatchQueue.main.async {
            child.view.frame = super.view.frame
            super.view.addSubview(child.view)
            child.view.superview?.bringSubviewToFront(child.view)
            child.didMove(toParent: self)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}
