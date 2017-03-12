//
//  Utilities.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

protocol Xib_Protocol { }

//MARK: - Initialization
extension Xib_Protocol where Self: UIView {
    func initialization(_ xibBundleName: String) {
        let view = Bundle.main.loadNibNamed(xibBundleName, owner: self, options: nil)?.first as! UIView //xib파일 찾아서 연결
        view.frame = bounds //현재 뷰의 크기 지정
        view.translatesAutoresizingMaskIntoConstraints = true //오토 사이징 설정
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight] //오토 사이징 적용할 제약사항 : 가로, 세로 모두
        
        addSubview(view) //자신에게 추가
    }
}

class OnTheMapViewController: UIViewController { }

extension OnTheMapViewController {
    func openURL(_ urlString: String) {
        guard urlString != "" else {
            return
        }
        
        let mediaURL = URL(string: urlString)
        
        if UIApplication.shared.canOpenURL(mediaURL!) {
            UIApplication.shared.open(mediaURL!, options: [:], completionHandler: nil)
        }
    }
    
    func refreshAction() { }
}

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

protocol Spinner_Protocol {
    weak var spinner: UIActivityIndicatorView! { get set }
}

extension Spinner_Protocol {
    func spinnerAimation(_ isTrue: Bool) {
        if isTrue {
            spinner.isHidden = false
            spinner.startAnimating()
        } else {
            spinner.isHidden = true
            spinner.stopAnimating()
        }
    }
}
