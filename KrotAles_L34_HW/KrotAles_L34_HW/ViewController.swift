//
//  ViewController.swift
//  KrotAles_L34_HW
//
//  Created by Ales Krot on 16.02.22.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class ViewController: UIViewController {
    @IBOutlet weak var logInTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    //    @IBOutlet weak var termAndConditionsToggle: UISwitch!
    //    @IBOutlet weak var passwordTextField: UITextField!
    //    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let bag = DisposeBag()
    let server = Server()
//    var isValidLogIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInTextField.delegate = self
        
        let loginTextObservable = logInTextField.rx.text.asObservable()
        let logInButtonObservable = logInButton.rx.tap.asObservable()

        let isValidLogIn = BehaviorRelay<Bool>(value: true)
        
        let observable = logInButtonObservable.withLatestFrom(loginTextObservable)
        observable.subscribe(onNext: { login in
                self.server.signIn(login: login!) { [weak self] response in
                    DispatchQueue.main.async {
                        switch response {
                        case .success(_):
                            self?.infoLabel.text = "Login is correct"
                            isValidLogIn.accept(false)
                        case .failure(let error):
                            if case ServerError.wrongLogin = error {
                                self?.infoLabel.text = "Wrong login"
                                isValidLogIn.accept(true)
                            }
                        }
                    }
                }
            })
            .disposed(by: bag)
        
        logInTextField.rx.text
            .map { login in
                !(login?.isEmpty ?? true) }
            .bind(to: logInButton.rx.isEnabled)
            .disposed(by: bag)
        
        let logOutTappedButtonObservable = logOutButton.rx.tap.asObservable()
        let observerLogOutButton = logOutButton.rx.isHidden
        let observable2 = logOutTappedButtonObservable.withLatestFrom(isValidLogIn)
        observable2.subscribe(onNext: { _ in
            isValidLogIn.accept(true)
            self.infoLabel.text = "Enter your login"
        })
            .disposed(by: bag)
        
        isValidLogIn.subscribe(observerLogOutButton)
            .disposed(by: bag)
        
        let months = Observable.of("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
        let days = Observable.of(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
        
        let summary = Observable.zip(months, days) { month, days in
            return "\(month) has \(days) days"
        }
        
        summary.subscribe(onNext: { print($0) })
            .disposed(by: bag)
        
        //        logOutButtonObservable.subscribe(observerLogOutButton)
        //            .bind(to: logOutButton.rx.isHidden)
        //            .disposed(by: bag)
        
        //        let loginObservable = loginTextField.rx.text.asObservable()
        
//                let isLoginValid = loginTextField.rx.text
//                    .map { login in self.isValid(login: login)}
        //
        //        let isPasswordValid = passwordTextField.rx.text
        //            .map { password in (password?.count ?? 0) > 8  }
        //
        //        let isToggleOn = termAndConditionsToggle.rx.isOn.asObservable()
        //
        //        let passwordsTheSame = Observable.combineLatest(
        //            passwordTextField.rx.text.asObservable(),
        //            confirmPasswordTextField.rx.text.asObservable()) { value1, value2 in
        //                value1 == value2
        //        }
        //
        //        Observable
        //            .combineLatest(isLoginValid, isPasswordValid, passwordsTheSame, isToggleOn)
        //            .map { isLoginValid, isPasswordValid, passwordsTheSame, isToggleOn -> String in
        //                var messages = [String]()
        //                if !isLoginValid { messages.append("Login is invalid.") }
        //                if !isPasswordValid { messages.append("Password is invalid.") }
        //                if !passwordsTheSame { messages.append("Passwords are different") }
        //                if !isToggleOn { messages.append("Please confirm terms and conditions.") }
        //                return messages.joined(separator: "\n")
        //            }
        //            .bind(to: infoLabel.rx.text)
        //
        //        Observable
        //            .combineLatest(isLoginValid, isPasswordValid, passwordsTheSame, isToggleOn) {
        //                $0 && $1 && $2 && $3
        //            }
        //            .bind(to: signUpButton.rx.isEnabled)
        //            .disposed(by: bag)
        //
        //        let observable = Observable.from([3, 3, 5, 3, 6, 3, 6, 2, 6])
        
        //        observable.subscribe { event in
        //            print("observable emits: \(event)")
        //        }.disposed(by: bag)
        //
        //        let subscription = observable.subscribe(onNext: { print($0) },
        //                             onError: nil,
        //                             onCompleted: { print("completed")},
        //                             onDisposed: { print("disposed") })
        //    }
        //
        //    func isValid(login: String?) -> Bool {
        //        guard let login = login, !login.isEmpty else { return false }
        //        guard login.count > 5 else { return false }
        //        guard login.first?.isUppercase ?? false else { return false }
        //
        //        return true
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
