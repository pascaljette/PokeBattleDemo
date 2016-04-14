# PokeBattleDemo
Demo using pokeapi

# Installation
This uses XCode 7.3 (Swift 2.2).

# Design Philosophy

## No Storyboards
We are not using storyboards because we want to instantiate UIViewControllers using constructor dependency injection.  This facilitates our screen transition and makes sure that view controllers that require a model object are instantiated with the proper object without having to do additional optional handling.

## Humble Object
The ViewControllers are designed to be as lean as possible, where most of the logic is delegated to other, reusable classes.

# Things that are missing (aka TODO)

## Automated testing
Integrate with Travis CI and build automated tests to validate the application.  Because of it's random nature, it might be hard to test with snapshots thought.

## Better UI
UI could be improved.

## Cache integration
Calls to PokeApi are costly.  They even recommend on their own site to use a cache system if we are to do api calls often.  Due to the size and nature of the data, saving to user preferences is discourages.  It would probably be best to use SQLite and build a simple database for caching the PokeApi requests.

