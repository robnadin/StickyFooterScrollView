//
//  StickyFooterScrollView.swift
//  ScrollViewLayout
//
//  Created by Rob Nadin on 21/10/2017.
//  Copyright © 2017 Rob Nadin. All rights reserved.
//

import UIKit

final class StickyFooterScrollView: UIView {
    
    private struct Constants {
        static let contentWidthMultiplier: CGFloat = 0.75
        static let backgroundImageAspectRatio: CGFloat = 534 / 414
        static let safeZoneHeightProportion: CGFloat = 0.66
    }
    
    private let scrollView = UIScrollView()
    private let contentContainerView = UIView()
    private let backgroundImageView = UIView()
    
    var contentOffset: CGPoint {
        get {
            return scrollView.contentOffset
        }
        set {
            scrollView.contentOffset = newValue
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let contentView = contentView {
                contentView.translatesAutoresizingMaskIntoConstraints = false
                contentContainerView.addSubview(contentView)
                NSLayoutConstraint.activate([
                    contentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
                    contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
                    contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
                    contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
                ])
            }
            
            setNeedsLayout()
        }
    }
    
    private(set) lazy var safeZoneLayoutGuide: UILayoutGuide = {
        let layoutGuide = UILayoutGuide()
        layoutGuide.identifier = "\(type(of: self))-safeZoneLayoutGuide"
        self.addLayoutGuide(layoutGuide)
        NSLayoutConstraint.activate([
            layoutGuide.leadingAnchor.constraint(equalTo: self.backgroundImageView.leadingAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor),
            layoutGuide.trailingAnchor.constraint(equalTo: self.backgroundImageView.trailingAnchor),
            layoutGuide.heightAnchor.constraint(equalTo: self.backgroundImageView.heightAnchor, multiplier: Constants.safeZoneHeightProportion),
        ])
        return layoutGuide
    }()
    
    private lazy var backgroundViewBottomConstraint: NSLayoutConstraint = {
        return self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    }()
    
    private lazy var scrollViewDelegate = ScrollViewDelegate { [weak self] _ in
        self?.updateBackgroundViewConstraints()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setUpScrollView()
        setUpContentContainerView()
        setUpBackgroundImageView()
    }
    
    private func setUpScrollView() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.delegate = scrollViewDelegate
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        let scrollViewContentContainerView = UIView()
        scrollViewContentContainerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollViewContentContainerView)
        NSLayoutConstraint.activate([
            scrollViewContentContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContentContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContentContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContentContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContentContainerView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    private func setUpContentContainerView() {
        contentContainerView.backgroundColor = .lightGray
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.subviews[0].addSubview(contentContainerView)
        NSLayoutConstraint.activate([
            contentContainerView.topAnchor.constraint(equalTo: scrollView.subviews[0].topAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: scrollView.subviews[0].bottomAnchor),
            contentContainerView.centerXAnchor.constraint(equalTo: scrollView.subviews[0].centerXAnchor),
            contentContainerView.widthAnchor.constraint(equalTo: scrollView.subviews[0].widthAnchor, multiplier: Constants.contentWidthMultiplier),
        ])
    }
    
    private func setUpBackgroundImageView() {
        backgroundImageView.backgroundColor = .blue
        backgroundImageView.isUserInteractionEnabled = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundImageView, belowSubview: scrollView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: backgroundImageView.widthAnchor, multiplier: Constants.backgroundImageAspectRatio),
            backgroundViewBottomConstraint,
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentInset.top = contentInset.top
        scrollView.contentInset.bottom = contentInset.bottom + safeZoneLayoutGuide.layoutFrame.height
        scrollView.layoutIfNeeded()
        updateBackgroundViewConstraints()
    }
    
    private func updateBackgroundViewConstraints() {
        let usableContentHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.height
        let constant = bottomEdge - usableContentHeight
        backgroundViewBottomConstraint.constant = -min(0, constant)
    }
}

private extension StickyFooterScrollView {
    
    final class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
        
        private var didScrollHandler: ((UIScrollView) -> Void)?
        
        init(didScrollHandler: @escaping (UIScrollView) -> Void) {
            self.didScrollHandler = didScrollHandler
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            didScrollHandler?(scrollView)
        }
    }
}
