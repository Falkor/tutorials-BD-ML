-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

![By Falkor](https://img.shields.io/badge/by-Falkor-blue.svg) [![github](https://img.shields.io/badge/git-github-lightgray.svg)](https://github.com/Falkor/tutorials-bd-ml) [![Issues](https://img.shields.io/badge/issues-github-green.svg)](https://github.com/Falkor/tutorials-BD-ML/issues)

       Time-stamp: <Tue 2017-04-04 12:01 svarrette>

         _         _             _       _            ____  _____         __  __ _      
        | |       | |           (_)     | |          |  _ \|  __ \       |  \/  | |     
        | |_ _   _| |_ ___  _ __ _  __ _| |___ ______| |_) | |  | |______| \  / | |     
        | __| | | | __/ _ \| '__| |/ _` | / __|______|  _ <| |  | |______| |\/| | |     
        | |_| |_| | |_ (_) | |  | | (_| | \__ \      | |_) | |__| |      | |  | | |____ 
         \__|\__,_|\__\___/|_|  |_|\__,_|_|___/      |____/|_____/       |_|  |_|______|
                                                                                        
                                                                                        
       Copyright (c) 2018 Sebastien Varrette <Sebastien.Varrette@uni.lu>


## Synopsis

Tutorial on Big Data Analytics given at the occasion of the 3rd NESUS Winter School and PhD Symposium on Data Science and Heterogeneous Computing

## Installation / Repository Setup

This repository is hosted on [Github](https://github.com/Falkor/tutorials-BD-ML).

* To clone this repository, proceed as follows (adapt accordingly):

        $> mkdir -p ~/git/github.com/Falkor
        $> cd ~/git/github.com/Falkor
        $> git clone git@github.com:Falkor/tutorials-BD-ML.git


**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running:

    $> cd tutorials-bd-ml
    $> make setup

This will initiate the [Git submodules of this repository](.gitmodules) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

Later on, you can upgrade the [Git submodules](.gitmodules) to the latest version by running:

    $> make upgrade

If upon pulling the repository, you end in a state where another collaborator have upgraded the Git submodules for this repository, you'll end in a dirty state (as reported by modifications within the `.submodules/` directory). In that case, just after the pull, you **have to run** the following to ensure consistency with regards the Git submodules:

    $> make update

## Issues / Feature request

You can submit bug / issues / feature request using the [`Falkor/tutorials-bd-ml` Project Tracker](https://github.com/Falkor/tutorials-BD-ML/issues)



## Advanced Topics

### Git

This repository make use of [Git](http://git-scm.com/) such that you should have it installed on your working machine: 

       $> apt-get install git-core # On Debian-like systems
       $> yum install git          # On CentOS-like systems
       $> brew install git         # On Mac OS, using [Homebrew](http://mxcl.github.com/homebrew/)
       $> port install git         # On Mac OS, using MacPort

Consider these resources to become more familiar (if not yet) with Git:

* [Simple Git Guide](http://rogerdudler.github.io/git-guide/)
* [Git book](http://book.git-scm.com/index.html)
* [Github:help](http://help.github.com/mac-set-up-git/)
* [Git reference](http://gitref.org/)

At least, you shall configure the following variables

       $> git config --global user.name "Your Name Comes Here"
       $> git config --global user.email you@yourdomain.example.com
       # configure colors
       $> git config --global color.diff auto
       $> git config --global color.status auto
       $> git config --global color.branch auto

Note that you can create git command aliases in `~/.gitconfig` as follows: 

       [alias]
           up = pull origin
           pu = push origin
           st = status
           df = diff
           ci = commit -s
           br = branch
           w  = whatchanged --abbrev-commit
           ls = ls-files
           gr = log --graph --oneline --decorate
           amend = commit --amend

Consider my personal [`.gitconfig`](https://github.com/Falkor/dotfiles/blob/master/git/.gitconfig) as an example -- if you decide to use it, simply copy it in your home directory and adapt the `[user]` section. 

### [Git-flow](https://github.com/petervanderdoes/gitflow-avh)

The Git branching model for this repository follows the guidelines of
[gitflow](http://nvie.com/posts/a-successful-git-branching-model/).
In particular, the central repository holds two main branches with an infinite lifetime:

* `production`: the *production-ready* branch
* `master`: the main branch where the latest developments interviene. This is the *default* branch you get when you clone the repository.

Thus you are more than encouraged to install the [git-flow](https://github.com/petervanderdoes/gitflow-avh) (AVH Edition, as the traditional one is no longer supported) extensions following the [installation procedures](https://github.com/petervanderdoes/gitflow-avh/wiki/Installation) to take full advantage of the proposed operations. The associated [bash completion](https://github.com/bobthecow/git-flow-completion) might interest you also.

### Releasing mechanism

The operation consisting of releasing a new version of this repository is automated by a set of tasks within the root `Makefile`.

In this context, a version number have the following format:

      <major>.<minor>.<patch>[-b<build>]

where:

* `< major >` corresponds to the major version number
* `< minor >` corresponds to the minor version number
* `< patch >` corresponds to the patching version number
* (eventually) `< build >` states the build number _i.e._ the total number of commits within the `master` branch.

Example: \`1.0.0-b28\`

The current version number is stored in the root file `VERSION`. __/!\ NEVER MAKE ANY MANUAL CHANGES TO THIS FILE__

For more information on the version, run:

     $> make versioninfo

If a new version number such be bumped, you simply have to run:

      $> make start_bump_{major,minor,patch}

This will start the release process for you using `git-flow`.
Once you have finished to commit your last changes, make the release effective by running:

      $> make release

It will finish the release using `git-flow`, create the appropriate tag in the `production` branch and merge all things the way they should be.


## Contributing

That's quite simple:

1. [Fork](https://help.github.com/articles/fork-a-repo/) it
2. Create your own feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new [Pull Request](https://help.github.com/articles/using-pull-requests/)
