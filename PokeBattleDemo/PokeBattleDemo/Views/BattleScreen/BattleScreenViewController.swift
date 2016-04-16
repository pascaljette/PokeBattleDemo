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
// Use a TableView with cells that contain 2 buttons.  This will also give us 
// the height of the whole thing
class BattleScreenViewController : GKViewControllerBase {
    
    //
    // MARK: Nested types.
    //
    
    typealias GetPokemonListConnection = PokeApiConnection<GetPokemonListRequest, GetPokemonListResponse>
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>

    //
    // MARK: IBOutlets.
    //

    @IBOutlet weak var team1poke1: BattleScreenTile!
    
    @IBOutlet weak var team1poke2: BattleScreenTile!

    @IBOutlet weak var team1poke3: BattleScreenTile!

    @IBOutlet weak var team2poke1: BattleScreenTile!

    @IBOutlet weak var team2poke2: BattleScreenTile!

    @IBOutlet weak var team2poke3: BattleScreenTile!

    @IBOutlet weak var actionButton: UIButton!
    
    // TODO no no no.  Do not keep a reference on the processing tile.  There might be several and then
    // we have to refactor the whole thing.
    private var processingTile: BattleScreenTile!
    
    private var pokemonList: AllPokemonList
    private var initialDrawPlayer1: [Pokemon]
    private var initialDrawPlayer2: [Pokemon]
    
    private var stateMachine: StateMachine = StateMachine()
    
    private var pokemonFetcher: PokemonFetcher
    
    //
    // MARK: Initialisation.
    //
    
    /// Initialise with a model.
    ///
    /// - parameter model: Model to use to initialise the view controller.
    init(pokemonList: AllPokemonList
        , initialDrawPlayer1: [Pokemon]
        , initialDrawPlayer2: [Pokemon]
        , pokemonFetcher: PokemonFetcher) {
        
        self.pokemonList = pokemonList
        self.initialDrawPlayer1 = initialDrawPlayer1
        self.initialDrawPlayer2 = initialDrawPlayer2
        self.pokemonFetcher = pokemonFetcher
        
        super.init(nibName: "BattleScreenViewController", bundle: nil)
        
        stateMachine.delegate = self
        self.pokemonFetcher.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported (no storyboard support)")
    }
    
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
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        team1poke1.pokemon = initialDrawPlayer1[0]
        team1poke2.pokemon = initialDrawPlayer1[1]
        team1poke3.pokemon = initialDrawPlayer1[2]

        team2poke1.pokemon = initialDrawPlayer2[0]
        team2poke2.pokemon = initialDrawPlayer2[1]
        team2poke3.pokemon = initialDrawPlayer2[2]
    }
    
    @IBAction func fightButtonPressed(sender: AnyObject) {
        
        stateMachine.currentState?.actionButtonPressed()
    }
}

extension BattleScreenViewController : StateMachineDelegate {
    
    func didPressSkipButton() {
        
        print("skip")
        stateMachine.proceedToNextState()
    }
    
    func didPressFightButton() {
        
        print("fight")
    }
    
    func didPressStartButton() {
        
        print("start")
        stateMachine.proceedToNextState()
    }

    func setupViewForInitialState() {
        
        GKThread.dispatchOnUiThread { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.actionButton.enabled = true
            strongSelf.actionButton.setTitle(strongSelf.stateMachine.currentState?.actionButtonText
                , forState: .Normal)
            
            strongSelf.team1poke1.imageButton.enabled = false
            strongSelf.team1poke2.imageButton.enabled = false
            strongSelf.team1poke3.imageButton.enabled = false
            
            strongSelf.team2poke1.imageButton.enabled = false
            strongSelf.team2poke2.imageButton.enabled = false
            strongSelf.team2poke3.imageButton.enabled = false
        }
    }
    
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
    
    func setupViewForFightState() {
        
        GKThread.dispatchOnUiThread { [ weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.actionButton.enabled = true
            strongSelf.actionButton.setTitle(strongSelf.stateMachine.currentState?.actionButtonText
                , forState: .Normal)

            strongSelf.team1poke1.imageButton.enabled = false
            strongSelf.team1poke2.imageButton.enabled = false
            strongSelf.team1poke3.imageButton.enabled = false
            
            strongSelf.team2poke1.imageButton.enabled = false
            strongSelf.team2poke2.imageButton.enabled = false
            strongSelf.team2poke3.imageButton.enabled = false

        }
    }
}

extension BattleScreenViewController : BattleScreenTileDelegate {
    
    func tileButtonPressed(sender: BattleScreenTile) {
        
        processingTile = sender
        
        GKThread.dispatchOnUiThread {
            
            sender.loading = true
        }
    
        actionButton.enabled = false
        pokemonFetcher.fetch()
    }

}

extension BattleScreenViewController : PokemonFetcherDelegate {
    
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?) {
        
        if success {
            
            processingTile.pokemon = result
            
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

