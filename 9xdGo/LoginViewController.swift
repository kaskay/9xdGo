//
//  LoginViewController.swift
//  9xdGo
//
//  Created by 이규진 on 2017. 9. 9..
//  Copyright © 2017년 이재성. All rights reserved.
//

import UIKit

import FBSDKLoginKit
import SwiftyJSON

class LoginViewController: UIViewController {
    @IBOutlet var topImage: UIImageView!
    @IBOutlet var bottomImage: UIImageView!
    @IBOutlet var topImageLeft: NSLayoutConstraint!
    @IBOutlet var topImageTop: NSLayoutConstraint!
    let loginButton = FBSDKLoginButton()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.topImage.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (t) -> Void in
            self.topImage.alpha = 1
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 1, delay: 0.5, options: [.autoreverse, .repeat], animations: {
            self.bottomImage.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { (t) -> Void in
            self.bottomImage.alpha = 1
            self.view.layoutIfNeeded()
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loginButton.frame = CGRect(x: -100, y: -100, width: 0, height: 0)
        view.addSubview(loginButton)
        
        // set facebook login permission
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.delegate = self
        
        UserInfoService.shared.delegate = self
        
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveCurrentProfile(notification:)), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
    }
    
    func sign(userInfo: UserInfo) {
        NetworkService.shared.postFacebookSign(
            id: userInfo.fbId,
            token: userInfo.authToken,
            name: userInfo.name,
            imageURL: userInfo.thumnailURLStr
        ) { [weak self] in
            guard let `self` = self else { return }
            let data = JSON($0)
            let id = data["id"].intValue
            UserDefaultsService.shared.id = id
            print("user id : \(id)")
            self.dismiss(animated: true)
        }
    }
    
    func getUserInfo() {
        if let accessToken = FBSDKAccessToken.current(),
            let profile = FBSDKProfile.current() {
            UserInfoService.shared.fetchUserInfo(accessToken: accessToken, profile: profile)
        }
    }
    
    func didReceiveCurrentProfile(notification: NSNotification) {
        // fb 로그인 성공시 호출
        getUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        loginButton.sendActions(for: .touchUpInside)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        print("loginButtonWillLogin")
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print("facebook login error : \(error.localizedDescription)")
        } else if result.isCancelled {
            print("facebook login cancelled")
        } else {
            print("facebook login succeeded")
            self.getUserInfo()
        }
    }
}

extension LoginViewController: UserInfoServiceDelegate {
    func userInfo(didUpdateUserInfo userInfo: UserInfo) {
        self.sign(userInfo: userInfo)
    }
}
