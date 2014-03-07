# battlemidget emacs (f0rked)

## Installation

You could install this and have my working setup, but lets be honest,
why would you?

Fetch the emacs source files:

    $ git clone git://github.com/battlemidget/emacs.git ~/.emacs.d

Fetch my snippets submodule:

    $ cd ~/.emacs.d
    $ git submodule init
    $ git submodule update

Install all ELPA packages (make sure you have
[Cask](https://github.com/cask/cask) installed):

    $ cd ~/.emacs.d
    $ cask
