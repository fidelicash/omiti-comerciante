//
//  LoginVC.swift
//  FideliCash-Comerciante
//
//  Created by Carlos Doki on 09/06/18.
//  Copyright © 2018 Carlos Doki. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import SwiftKeychainWrapper
import FirebaseAuth
import Firebase

class LoginVC: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate  {
    
    
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = FBSDKLoginButton()
        loginView.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: 50, width: loginView.frame.width - 32, height: 50)
        loginButton.delegate = self
        
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 120, width: loginView.frame.width - 32, height: 50)
        loginView.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout Facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Sucessfully logged in with Facebook...")
        let credentials = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            userUUID = uid
            let ref = Database.database().reference()
            let users = ref.child("users").child(uid)
            users.child("saldo").setValue(0)
            users.child("cpf").setValue("")
            users.child("IDFacebook").setValue(user?.uid)
            users.child("IDGoogle").setValue("")
            users.child("nome").setValue(user?.displayName)
            
            let keychainResult = KeychainWrapper.standard.set((user?.uid)!, forKey: KEY_UID)
            print("DOKI: Data saved to keychain \(keychainResult)")
            
            print("Firebase user created", uid)
            self.performSegue(withIdentifier: "menuinicial", sender: nil)
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //let defaults = UserDefaults.standard
        //defaults.set("54FjYF8UwBS5IVbeitX9Pq6IbfF3", forKey: "authVID")
        //let keychainResult = KeychainWrapper.standard.set(("54FjYF8UwBS5IVbeitX9Pq6IbfF3"), forKey: KEY_UID)
        
        if let user = KeychainWrapper.standard.string(forKey: KEY_UID) {
            userUUID = user
            print("DOKI: ID found in keychain")
            performSegue(withIdentifier: "menuinicial", sender: nil)
        } else {
        }
    }
    
}

