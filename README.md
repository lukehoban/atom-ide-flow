# Atom IDE support for Flow

Adds several IDE features for Facebook Flow language to Atom:
* Hover tooltips show types when mouse hovers over variables
* Typecheck on save reports errors with red highlights and gutter indicators
* Go to definition command navigates to the definition of a variable
* Autocomplete shows type-based completion lists [NOTE: Must install `autocomplete-plus` plugin]

Heavily inspired by [IDE Haskell](https://atom.io/packages/ide-haskell).

## Demo
![Feature demo](https://github.com/lukehoban/atom-ide-flow/raw/master/ideflow.gif)

## Requirements

* [Flow](https://github.com/facebook/flow)
* [autocomplete-plus](https://atom.io/packages/autocomplete-plus)

## Installation

    $ apm install ide-flow

## Notes

* If the `flow` command is not on your path, set it's location in the package
  settings under `Flow Path`
* Automatically starts a flow server if not already active in a given folder.  
  If you need to set configurations on the flow server (such as a --lib flag),
  run a server manually in the folder you are working in.
