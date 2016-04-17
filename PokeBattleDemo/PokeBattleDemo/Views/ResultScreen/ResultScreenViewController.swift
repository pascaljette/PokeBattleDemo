//
//  ResultScreenViewController.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/17/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import UIKit
import GearKit

class ResultScreenViewController : GKViewControllerBase {
    
    
    //
    // MARK: IBOutlets
    //
    @IBOutlet weak var player1DamageLabel: UILabel!

    @IBOutlet weak var player2DamageLabel: UILabel!
    
    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBOutlet weak var winsLabel: UILabel!

    @IBOutlet weak var oneMore: UIButton!

    //
    // MARK: Stored properties
    //
    var battleResult: BattleResult
    
    //
    // MARK: Initialization
    //

    /// Initialise with a model.
    init(battleResult: BattleResult) {
        
        self.battleResult = battleResult
        
        super.init(nibName: "ResultScreenViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented (storyboard not supported)")
    }
}

extension ResultScreenViewController {
    
    //
    // MARK: UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        player1DamageLabel.text = String(battleResult.player1Result.score)
        player2DamageLabel.text = String(battleResult.player2Result.score)

        winnerLabel.hidden = true
        winsLabel.hidden = true
        oneMore.hidden = true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        guard let winner = battleResult.winner else{
            
            winnerLabel.hidden = false
            winnerLabel.text = "DRAW"
            winsLabel.hidden = true
            oneMore.hidden = false
            
            return
        }
    
        let winnerText: String
        switch winner.id {
            
        case .PLAYER_1:
            winnerText = "Player 1"
            
        case .PLAYER_2:
            winnerText = "Player 2"
        }
        
        winnerLabel.text = winnerText
        winnerLabel.hidden = false
        
        let initialScaleFactor: CGFloat = 10.0
        
        winnerLabel.transform = CGAffineTransformScale(winnerLabel.transform, 1.0 / initialScaleFactor, 1.0 / initialScaleFactor);
        
        UIView.animateWithDuration(1.0, animations:{
        
            self.winnerLabel.transform = CGAffineTransformScale(self.winnerLabel.transform, initialScaleFactor, initialScaleFactor);
            }, completion: { _ in
                
                self.winsLabel.hidden = false
                self.oneMore.hidden = false
        })
    }
}

extension ResultScreenViewController {
    
    //
    // MARK: IBAction
    //

    @IBAction func oneMoreButtonPressed(sender: AnyObject) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
