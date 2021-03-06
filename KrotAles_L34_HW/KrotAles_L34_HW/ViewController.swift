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
    
    let bag = DisposeBag()
    let server = Server()
    
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
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
