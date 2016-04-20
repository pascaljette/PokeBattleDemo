// The MIT License (MIT)
//
// Copyright (c) 2015 pascaljette
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation
import UIKit
import GearKit

/// Displays the result after the battle results have been computed.
class ResultScreenViewController : GKViewControllerBase {
    
    //
    // MARK: IBOutlets
    //
    
    /// Title of the damage dealt by player 1.
    @IBOutlet weak var player1ScoreTitleLabel: UILabel!
    
    /// Value of the damage dealt by player 1.
    @IBOutlet weak var player1DamageLabel: UILabel!

    /// Title of the damage dealt by player 1.
    @IBOutlet weak var player2ScoreTitleLabel: UILabel!
    
    /// Value of the damage dealt by player 2.
    @IBOutlet weak var player2DamageLabel: UILabel!
    
    /// Name of the player who won.
    @IBOutlet weak var winnerLabel: UILabel!
    
    /// Label that displays the win string.
    @IBOutlet weak var winsLabel: UILabel!

    /// Button used for one more game.
    @IBOutlet weak var revengeButton: UIButton!

    /// Button used for one more game with re-shuffle.
    @IBOutlet weak var reShuffleButton: UIButton!
    
    //
    // MARK: Stored properties
    //
    var battleResult: BattleResult
    
    //
    // MARK: Initialization
    //

    /// Initialise with battle result computed from the engine.
    ///
    /// - parameter battleResult: Result containing scores from both players.
    init(battleResult: BattleResult) {
        
        self.battleResult = battleResult
        
        super.init(nibName: "ResultScreenViewController", bundle: nil)
    }
    
    /// Required initialiser.  Unsupported so make it crash as soon as possible.
    ///
    /// - parameter coder: Coder used to initialize the view controller (when instantiated from a storyboard).
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented (storyboard not supported)")
    }
}

extension ResultScreenViewController {
    
    //
    // MARK: UIViewController overrides
    //
    
    /// View did load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        player1ScoreTitleLabel.text = NSLocalizedString("PLAYER_1_SCORE", comment: "Player 1 score")
        player2ScoreTitleLabel.text = NSLocalizedString("PLAYER_2_SCORE", comment: "Player 2 score")

        player1DamageLabel.text = String(battleResult.player1Result.score)
        player2DamageLabel.text = String(battleResult.player2Result.score)

        revengeButton.setTitle(NSLocalizedString("REVENGE_BUTTON", comment: "Revenge Button")
            , forState: .Normal)
        
        reShuffleButton.setTitle(NSLocalizedString("RESHUFFLE_BUTTON", comment: "Reshuffle Button")
            , forState: .Normal)
        
        winsLabel.text = NSLocalizedString("WINNER", comment: "Winner label")
        
        winnerLabel.hidden = true
        winsLabel.hidden = true
        revengeButton.hidden = true
        reShuffleButton.hidden = true
    }
    
    /// View did appear.
    ///
    /// - parameter animated: Whether the view is being animated when it appears.
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Retrieve the playing winner.  Abort if it is a draw and displays the draw label.
        guard let winner = battleResult.winner else{
            
            winnerLabel.hidden = false
            winnerLabel.text = NSLocalizedString("DRAW", comment: "Draw")
            winsLabel.hidden = true
            revengeButton.hidden = false
            reShuffleButton.hidden = false
            
            return
        }
    
        // Set winner text to the corresponding player name.
        let winnerText: String
        switch winner.id {
            
        case .PLAYER_1:
            winnerText = NSLocalizedString("PLAYER_1", comment: "Player 1")
            
        case .PLAYER_2:
            winnerText = NSLocalizedString("PLAYER_2", comment: "Player 2")
        }
        
        // Initially hide the winner text since we will be animating it.
        winnerLabel.text = winnerText
        winnerLabel.hidden = false
        
        let initialScaleFactor: CGFloat = 10.0
        
        // Animate the winning player label by making it grow (scale).
        winnerLabel.transform = CGAffineTransformScale(winnerLabel.transform, 1.0 / initialScaleFactor, 1.0 / initialScaleFactor);
        
        UIView.animateWithDuration(1.0, animations:{
        
            self.winnerLabel.transform = CGAffineTransformScale(self.winnerLabel.transform, initialScaleFactor, initialScaleFactor);
            }, completion: { _ in
                
                // Display the additional UI elements after the animation completes.
                self.winsLabel.hidden = false
                self.revengeButton.hidden = false
                self.reShuffleButton.hidden = false
        })
    }
}

extension ResultScreenViewController {
    
    //
    // MARK: IBAction
    //

    /// One more button has been pressed.  Simply return to the root view controller. We will be using
    /// the same pokemon draw for the new game.
    ///
    /// - parameter sender: Object sending the event.
    @IBAction func revengeButtonPressed(sender: AnyObject) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /// Re-shuffle button has been pressed.  Trigger a reshuffle and return to the intro view controller.
    ///
    /// - parameter sender: Object sending the event.
    @IBAction func reShuffleButtonPressed(sender: AnyObject) {
        
        guard let introViewController = self.navigationController?.viewControllers[0] as? IntroScreenViewController else {
            
            return
        }
        
        introViewController.reshuffleDraw()
        self.navigationController?.popToViewController(introViewController, animated: true)
    }
}
