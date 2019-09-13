//
//  ViewController.swift
//  Cognito Test
//
//  Created by Fernando Perez on 9/12/19.
//  Copyright © 2019 Pet Safe. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var verifyCodeTextField: UITextField!
    @IBOutlet weak var verifyCodeButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    
    private var userPool: AWSCognitoIdentityUserPool? = nil
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var emailValue: String!
    
    private var customAuthCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityCustomChallengeDetails>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appDelegate.pool?.delegate = self
        emailTextField.text = "fernandoperez0330@gmail.com"
        //initialCognitoSetup()
        
        verifyCodeTextField.text = ""
        verifyCodeButton.isEnabled = false
        verifyCodeTextField.isEnabled = false
        addActions()
    }
    
    private func addActions(){
        self.signInButton.addTarget(self, action: #selector(self.clickSignIn(_:)), for: .touchUpInside)
        self.verifyCodeButton.addTarget(self, action: #selector(self.clickVerifyCode(_:)), for: .touchUpInside)

    }
    
    private func awsSignIn(username: String){
        emailValue = username
        DispatchQueue.main.async {
            self.resultTextView.text = ""
        }
        let user = appDelegate.pool?.getUser()
        self.customAuthCompletionSource = nil
        user?.getSession().continueWith(block: { task in
            if task.isFaulted, let error = (task.error as NSError?){
                if (error.code == 34){
                    self.awsSignUp(username: username)
                }else{
                    print("awsSignIn -> error: " + error.debugDescription)
                }
            }else{
                if let session = task.result{
                    let result = String(format: "Verification Success:\n\nSession Object:\n\naccessToken: %@\nexpirationTime: %@\nsessionToken: %@\nrefreshToken: %@",
                                        (session.accessToken?.tokenString.description ?? "N/A"),
                                        (session.expirationTime?.description ?? "N/A"),
                                        (session.idToken?.tokenString.description ?? "N/A"),
                                        (session.refreshToken?.tokenString.description ?? "N/A"))
                    DispatchQueue.main.async {
                        self.emailTextField.text = ""
                        self.verifyCodeTextField.text = ""
                        self.verifyCodeTextField.isEnabled = false
                        self.verifyCodeButton.isEnabled = false
                        self.resultTextView.text = result
                    }
                }
            }
            return nil
        })
    }
    
    private func awsSignUp(username: String){
        appDelegate.pool?.signUp(username, password: NSUUID().uuidString, userAttributes: [], validationData: nil).continueWith(block: { task in
            
            if task.isFaulted, let error = (task.error as NSError?){
                print("signUp -> error: " + error.debugDescription)
            }else{
                self.awsSignIn(username: username)
                print("signUp -> success")
            }
            return nil
        })
    }
    
    @objc func clickVerifyCode(_ sender: Any){
        let details = AWSCognitoIdentityCustomChallengeDetails(challengeResponses: [
            "USERNAME": emailValue,
            "ANSWER": verifyCodeTextField.text!
            ])
        customAuthCompletionSource?.set(result: details)
    }
    
    @objc func clickSignIn(_ sender: Any){
        guard let emailValue = emailTextField.text else{
            return
        }
        awsSignIn(username: emailValue)
    }
}

extension ViewController: AWSCognitoIdentityCustomAuthentication{
    func getCustomChallengeDetails(_ authenticationInput: AWSCognitoIdentityCustomAuthenticationInput, customAuthCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityCustomChallengeDetails>) {
        
        print("authenticationInput: " + authenticationInput.challengeParameters.debugDescription)
        
        if let _ = self.customAuthCompletionSource{
            self.customAuthCompletionSource = customAuthCompletionSource
            DispatchQueue.main.async {
                if (!(self.verifyCodeTextField.text?.isEmpty ?? true)){
                    let alert = UIAlertController(title: "Verify Code", message: "Invalid Token, please try again", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                self.verifyCodeTextField.text = ""
                self.verifyCodeButton.isEnabled = true
                self.verifyCodeTextField.isEnabled = true
            }
            return
        }
        
        let details = AWSCognitoIdentityCustomChallengeDetails(challengeResponses: [
            "USERNAME": emailValue
            ])
        details.initialChallengeName = "CUSTOM_CHALLENGE"
        self.customAuthCompletionSource = customAuthCompletionSource
        customAuthCompletionSource.set(result: details)
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = (error as NSError?){
                if (error.code == 34){
                    self.resultTextView.text = String(format: "New User Created: %@",self.emailValue)
                    self.awsSignUp(username: self.emailValue)
                    return
                }
                self.customAuthCompletionSource = nil
                print("AWSCognitoIdentityCustomAuthentication-> didCompleteStepWithError -> Error: " + error.debugDescription)
                let alert = UIAlertController(title: error.domain, message: error.code.description, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alert, animated: true, completion: nil)
                
            
            }else{
                print("AWSCognitoIdentityCustomAuthentication-> didCompleteStepWithError -> Success")
            }
        }
    }
}


extension ViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate{
    
    func startCustomAuthentication() -> AWSCognitoIdentityCustomAuthentication {
        return self
    }
}
