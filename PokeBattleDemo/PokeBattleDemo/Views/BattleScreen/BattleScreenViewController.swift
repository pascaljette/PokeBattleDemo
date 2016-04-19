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
import GearKit

// TODO There is a more flexible way to control the tiles in this view.
// Use a TableView with cells that contain 2 buttons or a collectionview.

/// Main screen for player interactions where the players draws are displayed.
class BattleScreenViewController : GKViewControllerBase {
    
    //
    // MARK: IBOutlets.
    //

    /// Player 1, topmost pokemon
    @IBOutlet weak var team1poke1: BattleScreenTile!
    
    /// Player 1, middle pokemon
    @IBOutlet weak var team1poke2: BattleScreenTile!

    /// Player 1, bottom pokemon
    @IBOutlet weak var team1poke3: BattleScreenTile!

    /// Player 2, topmost pokemon
    @IBOutlet weak var team2poke1: BattleScreenTile!

    /// Player 2, middle pokemon
    @IBOutlet weak var team2poke2: BattleScreenTile!

    /// Player 2, bottom pokemon
    @IBOutlet weak var team2poke3: BattleScreenTile!

    /// Action button for start, skip, fight, etc.
    @IBOutlet weak var actionButton: UIButton!
    
    //
    // MARK: Stored properties.
    //
    
    // TODO Do not keep a reference on the processing tile.  There might be several and then
    // we have to refactor the whole thing.
    
    /// Tile that requested to load a new pokemon.
    private var processingTile: BattleScreenTile!
    
    /// Reference on all possible downloadable pokemon
    private var pokemonList: AllPokemonList
    
    /// Reference on player 1
    private var player1: Player
    
    /// Reference on player 2
    private var player2: Player
    
    /// State machine used for the view's states.
    private var stateMachine: StateMachine
    
    /// Random pokemon fetcher for swap operations.
    private var pokemonFetcher: RandomPokemonFetcher
    
    /// Reference on the battle engine.
    private var battleEngine: BattleEngine
    
    //
    // MARK: Initialisation.
    //
    
    /// Initialise with a model.
    ///
    /// - parameter model: Model to use to initialise the view controller.
    init(pokemonList: AllPokemonList
        , player1: Player
        , player2: Player
        , pokemonFetcher: RandomPokemonFetcher
        , stateMachine: StateMachine
        , battleEngine: BattleEngine) {
        
        self.pokemonList = pokemonList
        self.player1 = player1
        self.player2 = player2
        self.pokemonFetcher = pokemonFetcher
        self.stateMachine = stateMachine
        self.battleEngine = battleEngine
        
        super.init(nibName: "BattleScreenViewController", bundle: nil)
        
        stateMachine.delegate = self
        self.pokemonFetcher.delegate = self
    }
    
    /// Required initialiser.  Unsupported so make it crash as soon as possible.
    ///
    /// - parameter coder: Coder used to initialize the view controller (when instantiated from a storyboard).
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported (no storyboard support)")
    }
    
}

extension BattleScreenViewController {
    
    //
    // MARK: UIViewController lifecycle
    //
    
    /// View did load. Setup navigation item and the tiles as well.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // TODO localize
        self.navigationItem.title = "Battle!"
        
        navigationItem.hidesBackButton = true
        
        team1poke1.delegate = self
        team1poke2.delegate = self
        team1poke3.delegate = self
        
        team2poke1.delegate = self
        team2poke2.delegate = self
        team2poke3.delegate = self
        
        stateMachine.start()
        
        GKThread.dispatchOnUiThread { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.team1poke1.loading = true
            strongSelf.team1poke2.loading = true
            strongSelf.team1poke3.loading = true
            
            strongSelf.team2poke1.loading = true
            strongSelf.team2poke2.loading = true
            strongSelf.team2poke3.loading = true
        }
    }
    
    /// View will appear.
    ///
    /// - parameter animated: Whether animated.
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        team1poke1.pokemon = player1.pokemonDraw[0]
        team1poke2.pokemon = player1.pokemonDraw[1]
        team1poke3.pokemon = player1.pokemonDraw[2]
        
        team2poke1.pokemon = player2.pokemonDraw[0]
        team2poke2.pokemon = player2.pokemonDraw[1]
        team2poke3.pokemon = player2.pokemonDraw[2]
    }
}

extension BattleScreenViewController : StateMachineDelegate {
    
    //
    // MARK: StateMachineDelegate implementation
    //
    
    /// Skip button action used in the player action state.
    func didPressSkipButton() {
        
        stateMachine.proceedToNextState()
    }
    
    /// Fight button action used after all the players' turns are finished.
    func didPressFightButton() {
        
        // TODO we shouldn't need to rebuild here
        player1.pokemonDraw = [team1poke1.pokemon!, team1poke2.pokemon!, team1poke3.pokemon!]
        player2.pokemonDraw = [team2poke1.pokemon!, team2poke2.pokemon!, team2poke3.pokemon!]

        actionButton.enabled = false
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            let battleResult = strongSelf.battleEngine.fight(player1: strongSelf.player1, player2: strongSelf.player2)

            GKThread.dispatchOnUiThread {
                
                strongSelf.navigationController?.pushViewController(ResultScreenViewController(battleResult: battleResult), animated: true)
            }
        }
    }
    
    /// Start button action used on the initial state.
    func didPressStartButton() {
        
        stateMachine.proceedToNextState()
    }

    /// Setup the view for the initial state.
    /// Disable all the player tiles.
    func setupViewForInitialState() {
        
        GKThread.dispatchOnUiThread { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.actionButton.enabled = true
            strongSelf.actionButton.setTitle(strongSelf.stateMachine.currentState?.actionButtonText
                , forState: .Normal)
            
            strongSelf.setEnabledStatusForAllTiles(false)
        }
    }
    
    /// Setup the view for the player action state.
    /// Enable only the current player's tiles.
    ///
    /// - parameter playerId: Id of the player to determine whose turn it is.
    func setupViewForPlayerActionState(playerId: PlayerId) {
        
        GKThread.dispatchOnUiThread { [weak self] in
           
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.actionButton.enabled = true
            strongSelf.actionButton.setTitle(strongSelf.stateMachine.currentState?.actionButtonText
                , forState: .Normal)

            strongSelf.team1poke1.imageButton.enabled = (playerId == .PLAYER_1)
            strongSelf.team1poke2.imageButton.enabled = (playerId == .PLAYER_1)
            strongSelf.team1poke3.imageButton.enabled = (playerId == .PLAYER_1)
            
            strongSelf.team2poke1.imageButton.enabled = (playerId == .PLAYER_2)
            strongSelf.team2poke2.imageButton.enabled = (playerId == .PLAYER_2)
            strongSelf.team2poke3.imageButton.enabled = (playerId == .PLAYER_2)
        }
    }
    
    /// Setup the view for the fight state after all actions are complete.
    /// Disable all pokemon tiles and enable the fight button.
    func setupViewForFightState() {
        
        GKThread.dispatchOnUiThread { [ weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.actionButton.enabled = true
            strongSelf.actionButton.setTitle(strongSelf.stateMachine.currentState?.actionButtonText
                , forState: .Normal)

            strongSelf.setEnabledStatusForAllTiles(false)
        }
    }
}

extension BattleScreenViewController : BattleScreenTileDelegate {
    
    //
    // MARK: BattleScreenTileDelegate implementation
    //
    
    /// A tile was pressed.  Disable everything until we get the new random pokemon.
    ///
    /// - parameter: Tile sending the event.
    func tileButtonPressed(sender: BattleScreenTile) {
        
        processingTile = sender
        
        GKThread.dispatchOnUiThread { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.setEnabledStatusForAllTiles(false)
            
            sender.loading = true
        }
    
        actionButton.enabled = false
        pokemonFetcher.fetch()
    }
}

extension BattleScreenViewController : RandomPokemonFetcherDelegate {
    
    //
    // MARK: RandomPokemonFetcherDelegate implementation
    //
    
    /// Did get random pokemon from pressing a tile.
    ///
    /// - parameter success: Whether the list retrieval succeeded.
    /// - parameter result: Retrieved list or nil on failure.
    /// - parameter error: Error object or nil on failure.
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?) {
        if success {
            
            GKThread.dispatchOnUiThread {
                
                self.processingTile.pokemon = result
            }
            
            stateMachine.proceedToNextState()
            
        } else {
            
            processingTile.loading = false
            
            // TODO push this into GearKit
            let alertController = UIAlertController(title: "Error", message: "Could not retrieve new pokemon", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }

    }
}

extension BattleScreenViewController {
    
    //
    // MARK: IBAction
    //
    
    /// Triggered when the action button is pressed.  It will go
    /// to the state machine and then call the proper function on its
    /// delegate depending on the current state.
    ///
    /// - parameter sender: The object triggering this event.
    @IBAction func actionButtonPressed(sender: AnyObject) {
        
        stateMachine.currentState?.actionButtonPressed()
    }
}

extension BattleScreenViewController {
    
    //
    // MARK: Private utility functions.
    //
    
    /// Set enabled status for all battle tiles.
    ///
    /// - parameter enabled: Enabled status to set for all tiles.
    private func setEnabledStatusForAllTiles(enabled: Bool) {
        
        team1poke1.imageButton.enabled = enabled
        team1poke2.imageButton.enabled = enabled
        team1poke3.imageButton.enabled = enabled
        
        team2poke1.imageButton.enabled = enabled
        team2poke2.imageButton.enabled = enabled
        team2poke3.imageButton.enabled = enabled

    }
}
