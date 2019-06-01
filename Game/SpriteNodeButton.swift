//
//  SpriteNodeButton.swift
//  Game Test 9
//
//  Created by Cat Blue on 12/3/17.
//

import SpriteKit

class SpriteNodeButton: SKSpriteNode {
    
    var validTouch = false
    
    var target: Any!
    var action: Selector!
    
    var disabled = false
    
    let label = SKLabelNode(fontNamed: "AppleSDGothicNeo-Regular")
    
    init(imageNamed: String, _ text: String = "") {
        let newTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: newTexture, color: UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0), size: newTexture.size())
        
        isUserInteractionEnabled = true
        
        if text != "" {
            label.zPosition = 1
            label.text = text
            label.fontSize = 12
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            addChild(label)
        }
        
        self.texture = texture
        self.color = color
        self.size = size
    }
    
    func addTarget(_ newTarget: Any?, newAction: Selector) {
        target = newTarget
        action = newAction
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        validTouch = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if self.contains(touch.location(in: parent!)) {
            }
            else {
                validTouch = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if validTouch {
            if target != nil && !disabled {
                UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
