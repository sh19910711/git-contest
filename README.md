# Git::Contest
`git-contest` is the Git Extension for Online Judges (Codeforces, etc...)

## Branching Model
![image](https://googledrive.com/host/0Bz19k_5gA4wVZWJEcW1XS25NRWM/git-contest.svg)

## Installation

Install [Ruby](https://www.ruby-lang.org/) (>= 1.9.2) and [Git](http://git-scm.com/) (>= 1.7), and type a following command:

    $ gem install git-contest

## Usage
There are 4 basic commands:

### init
Initialize a git repository.

    $ git contest init

### start
Start a contest branch.

    $ git contest start <contest-branch> [based-branch]

After this command, `<contest-branch>` is created based on `<based-branch>`.

### finish
Finish a contest branch.

    $ git contest finish <contest-branch>

After this command, `<contest-branch>` is merged into `<based-branch>`, and then removed.

### submit
Submit a code to the online judge.

    $ git contest submit <site>

## More Documentation
Use --help option as below:

    $ git contest <sub-command> ... --help

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Recently Status
[![Build Status](https://travis-ci.org/sh19910711/git-contest.png?branch=develop)](https://travis-ci.org/sh19910711/git-contest)
