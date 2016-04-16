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

protocol PokemonFetcherDelegate: class {
    
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?)
}

enum PokemonFetcherMode {
    
    case MANUAL(String)
    case RANDOM(AllPokemonList)
}

class PokemonFetcher {
    
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>
    
    weak var delegate: PokemonFetcherDelegate?
 
    var pokemonUrl: String
    
    init(fetcherMode: PokemonFetcherMode) {
        
        switch fetcherMode {
            
        case .MANUAL(let pokemonUrl):
            self.pokemonUrl = pokemonUrl
            
        case .RANDOM(let allPokemonList):
            self.pokemonUrl = allPokemonList.pokemonUrlStrings[Int(arc4random_uniform(UInt32(allPokemonList.pokemonUrlStrings.count)))]
        }
    }
}

extension PokemonFetcher {
    
    func fetch() {
        
        let call: GetPokemonConnection = GetPokemonConnection()
        let getPokemonRequest = GetPokemonRequest(fullUrl: pokemonUrl)
        
        call.onCompletion = { [weak self] (status, error, response) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            switch status {
                
            case .Success:
                strongSelf.delegate?.didGetPokemon(true, result: response?.model, error: nil)
                
            case .ConnectionError:
                strongSelf.delegate?.didGetPokemon(false, result: nil, error: error)
                
            case .UrlError:
                strongSelf.delegate?.didGetPokemon(false, result: nil, error: error)
            }
        }
        
        call.execute(getPokemonRequest)
    }
}

