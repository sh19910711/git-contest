# Git::Contest
**git-contest** is _the Git Extension for online judges_ (Codeforces, etc...)

[![Gem Version](https://badge.fury.io/rb/git-contest.png)](http://badge.fury.io/rb/git-contest)
[![Build Status](https://travis-ci.org/sh19910711/git-contest.png?branch=develop)](https://travis-ci.org/sh19910711/git-contest)

Currently support the following online judges:

* Codeforces
    * [http://codeforces.com/](http://codeforces.com/)
* Aizu Online Judge
    * [http://judge.u-aizu.ac.jp/onlinejudge/](http://judge.u-aizu.ac.jp/onlinejudge/)
* UVa Online Judge
    * [http://uva.onlinejudge.org/](http://uva.onlinejudge.org/)
* Kattis
    * [https://open.kattis.com/](https://open.kattis.com/)

## Branching Model
![image](https://googledrive.com/host/0Bz19k_5gA4wVZWJEcW1XS25NRWM/git-contest.png)

## Commit Message Examples
In this command, a commit having a judge status will be automatically created after submitting a solution to a online judge:

* `Cxdeforces 999A: Accepted`
* `Cxdeforces 999B: Wrong Answer`
* Also you can customize commit message

## Installation

Installation process takes a step, type a following command:

    $ gem install git-contest

### Requirements
Need to install:

* [Ruby](https://www.ruby-lang.org/)
    * `ruby --version` >= 1.9.3
* [Git](http://git-scm.com/)
    * `git --version` >= 1.7

## Command Usage
There are 4 basic sub-commands:

### init
Initialize a git repository.

    $ git contest init

### start
Start a contest branch.

    $ git contest start <contest-branch> [based-branch]

After this command, `<contest-branch>` is created based on `<based-branch>`.

Example:

    $ git contest start cxdeforces_round_123
    ->  the branch `cxdeforces_round_123` is created

### finish
Finish a contest branch.

    $ git contest finish <contest-branch>

After this command, `<contest-branch>` is merged into `<based-branch>`, and then removed.

Example:

    $ git contest finish cxdeforces_round_123
    ->  the branch `cxdeforces_round_123` is merged and closed

### submit
Submit a solution to the online judge.

    $ git contest submit <site>

Example:

    $ git contest submit cxdeforces -c 123 -p A
    -> submit a solution to cxdeforces 123A

#### Basic Options

##### Problem ID: `-p`, `--problem-id`

Type: `String`

Set problem-id, this option is used almost all sites.

    $ git contest submit site -p 10000

##### Contest ID: `-c`, `--contest-id`

Type: `String`

Set contest-id, this option is used codeforces.

    $ git contest submit site -c 123

##### Source File: `-s`, `--source`

Type: `String`, Default: `main.*`

Set submitting code's filename.

    $ git contest submit site -s source.cpp

##### Programming Lanaguage: `-l`, `--language`

Type: `String`

Set submitting code's programming language.

    $ git contest submit site -s source.cxx -l C++

When do not set this option, **git-contest** will resolve language from source filename. (`aaa.cpp` -> `C++`)

## More Documentation
Use --help option as belows:

Example 1:

    $ git contest --help

Example 2:

    $ git contest <sub-command> ... --help

## Configuration
### Options: environment variables
#### `GIT_CONTEST_HOME`
Type: `String`, Default: `~/.git-contest`

Set a path of git-contest home directory having a config file and plugins.

#### `GIT_CONTEST_CONFIG`
Type: `String`, Default: `${GIT_CONTEST_HOME}/config.yml`

Set a path of git-contest config file.

### `${GIT_CONTEST_HOME}/config.yml`
Write the information of online judges and git-contest settings to this file.

#### Example of `config.yml`
The site name can be set as you want.

```yaml
sites:
    codeforces:
        driver:     codeforces
        user:       your_codeforces_id
        password:   your_codeforces_password
    multi_account_aoj_1:
        driver:     aizu_online_judge
        user:       your_aoj_id_1
        password:   your_aoj_password_1
    multi_account_aoj_2:
        driver:     aizu_online_judge
        user:       your_aoj_id_2
        password:   your_aoj_password_2
    uva:
        driver:     uva_online_judge
        user:       your_uva_id
        password:   your_uva_password
    kattis:
        driver:     kattis
        user:       your_kattis_id
        password:   your_kattis_password
```

#### About contest drivers
Available drivers:

* codeforces
* aizu\_online\_judge
* uva\_online\_judge

You can write driver plugin on `${GIT_CONTEST_HOME}/plugins/driver_***.rb`

#### (TODO) How to write driver plugin
to be written here.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

* [Oskar Sundström](https://github.com/osund)
    * Added Kattis Driver
* [Wei Jianwen](https://github.com/weijianwen)
    * Fixed gem dependency

## Author Information

* [Hiroyuki Sano](http://yomogimochi.com/)
    * [GitHub - sh19910711](https://github.com/sh19910711)
    * [Google+](https://plus.google.com/+HiroyukiSano)

## License Information
**git-contest** is licensed under the MIT-License, see details followings:

The MIT License (MIT)

Copyright (c) 2013-2014 **Hiroyuki Sano** \<sh19910711 at gmail.com\>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Links
`git-contest` is inspired by [nvie/gitflow](https://github.com/nvie/gitflow).

* A successful Git branching model
    * [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)
* nvie/gitflow
    * [https://github.com/nvie/gitflow](https://github.com/nvie/gitflow)
* ruby
    * [https://www.ruby-lang.org/](https://www.ruby-lang.org/)
* git
    * [http://git-scm.com/](http://git-scm.com/)

