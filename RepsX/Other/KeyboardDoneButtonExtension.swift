//
//  KeyboardDoneButtonExtension.swift
//  RepsX
//
//  Created by Austin Hed on 4/26/25.
//

import SwiftUI

class KeyboardHostingController<Content: View>: UIHostingController<Content> {
  override var canBecomeFirstResponder: Bool { true }
  override var inputAccessoryView: UIView? {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let done = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(dismissKeyboard)
    )
    toolbar.items = [UIBarButtonItem.flexibleSpace(), done]
    return toolbar
  }

  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    becomeFirstResponder()
  }
}

import SwiftUI

/// A bridge that makes SwiftUI use your custom KeyboardHostingController
struct HostingControllerAdaptor<Content: View>: UIViewControllerRepresentable {
  let rootView: Content

  func makeUIViewController(context: Context) -> KeyboardHostingController<Content> {
    KeyboardHostingController(rootView: rootView)
  }

  func updateUIViewController(
    _ uiViewController: KeyboardHostingController<Content>,
    context: Context
  ) {
    // If you need to update the view hierarchy (e.g. pass new environment values),
    // assign to rootView here:
    uiViewController.rootView = rootView
  }
}
