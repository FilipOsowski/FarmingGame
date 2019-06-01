//
//  ConfirmOrCancel.swift
//  Game Test 9
//
//  Created by Cat Blue on 11/27/17.
//

import SpriteKit

class ConfirmOrCancel: SKNode {
    
    var confirmButton = SpriteNodeButton(imageNamed: "confirm")
    var cancelButton = SpriteNodeButton(imageNamed: "cancel")
    
    var validTouchCheck = ("", false)
    
    var delegate: ConfirmOrCancelDelegate?
    
    override init() {
        super.init()
        cancelButton.position = CGPoint(x: 30, y: 0)
        cancelButton.addTarget(self, newAction: #selector(cancel))
        addChild(cancelButton)
        
        confirmButton.position = CGPoint(x: -30, y: 0)
        confirmButton.addTarget(self, newAction: #selector(confirm))
        confirmButton.color = .darkGray
        addChild(confirmButton)
        
        isUserInteractionEnabled = true
    }
    
    @objc func cancel() {
        delegate?.cancel()
    }
    
    @objc func confirm() {
        delegate?.confirm()
    }
    
    func disableConfirmButton() {
        confirmButton.colorBlendFactor = 1
        confirmButton.disabled = true
    }
    
    func enableConfirmButton() {
        confirmButton.colorBlendFactor = 0
        confirmButton.disabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
