//
//  HideKeyboard.swift
//  MarvelShows
//
//  Created by M.Ibrahim on 13/07/2023.
//

import Foundation

class HideKeyboard {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    view.addGestureRecognizer(tapGesture)

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
