//
//  LottieView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import SwiftUI
import Lottie


struct LottieView: UIViewRepresentable {
    var name: String
    var loopMade: LottieLoopMode = .loop
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> some UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<LottieView>) {
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: uiView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor)
        ])
        
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMade
        animationView.play()
       
    }
}
