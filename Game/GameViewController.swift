//
//  GameViewController.swift
//  Game Test 2
//
//  Created by Cat Blue on 9/21/17.
//
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var myView: SKView!
    
    var myGameScene: GameScene!
    
    var myShopScene: ShopScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myView = self.view as! SKView
        myGameScene = GameScene(size: view.bounds.size, view: myView)
        
        myShopScene = ShopScene(size: view.bounds.size, cropProperties: myGameScene.cropProperties, gameDelegate: myGameScene)
        myGameScene.myShopScene = myShopScene
        
        myView.presentScene(myGameScene)
        myView.showsFPS = true
        myView.showsNodeCount = true
        myView.ignoresSiblingOrder = true
        
        let pinch = UIPinchGestureRecognizer(target: myGameScene, action: #selector(myGameScene.pinched(pinch:)))
        myView.addGestureRecognizer(pinch)
        pinch.delegate = myGameScene
        
        let pan = UIPanGestureRecognizer(target: myGameScene, action: #selector(self.myGameScene.panned(pan:)))
        myView.addGestureRecognizer(pan)
        pan.delegate = myGameScene
        
        let shopButton = UIButton(frame: CGRect(x: 25, y: 25, width: 100, height: 100))
        shopButton.setImage(UIImage(named: "plus"), for: .normal)
        shopButton.backgroundColor = .red
        
        shopButton.addTarget(self, action: #selector(changeShopState), for: .touchUpInside)
        
        myView.addSubview(shopButton)
    }
    
    @objc func changeShopState() {
        if let _ = myView.scene as? GameScene {
            myView.presentScene(myShopScene)
        }
        else {
            myView.presentScene(myGameScene)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
