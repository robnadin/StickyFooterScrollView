//
//  ViewController.swift
//  ScrollViewLayout
//
//  Created by Rob Nadin on 20/10/2017.
//  Copyright © 2017 Rob Nadin. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var stickyFooterScrollView: StickyFooterScrollView!
    @IBOutlet private weak var contentView: UIView!
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stickyFooterScrollView.contentView = contentView
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.centerXAnchor.constraint(equalTo: stickyFooterScrollView.safeZoneLayoutGuide.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: stickyFooterScrollView.safeZoneLayoutGuide.centerYAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 44),
            overlayView.heightAnchor.constraint(equalTo: overlayView.widthAnchor),
            //overlayView.widthAnchor.constraint(equalTo: stickyFooterScrollView.safeZoneLayoutGuide.widthAnchor),
            //overlayView.heightAnchor.constraint(equalTo: stickyFooterScrollView.safeZoneLayoutGuide.heightAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        var contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentInset.top += topLayoutGuide.length
        stickyFooterScrollView.contentInset = contentInset
        stickyFooterScrollView.contentOffset = CGPoint(x: 0, y: -contentInset.top)
    }
}
