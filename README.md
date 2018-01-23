-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

![By Falkor](https://img.shields.io/badge/by-Falkor-blue.svg)  [![Licence](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html) [![github](https://img.shields.io/badge/git-github-lightgray.svg)](https://github.com/Falkor/tutorials-bd-ml) [![Documentation Status](https://readthedocs.org/projects/nesusws-tutorials-bd-dl/badge/?version=latest)](http://nesusws-tutorials-bd-dl.readthedocs.io/en/latest/?badge=latest)


       Time-stamp: <Tue 2018-01-23 11:31 svarrette>

         ____  _         ____        _             _                _       _   _
        | __ )(_) __ _  |  _ \  __ _| |_ __ _     / \   _ __   __ _| |_   _| |_(_) ___ ___
        |  _ \| |/ _` | | | | |/ _` | __/ _` |   / _ \ | '_ \ / _` | | | | | __| |/ __/ __|
        | |_) | | (_| | | |_| | (_| | || (_| |  / ___ \| | | | (_| | | |_| | |_| | (__\__ \
        |____/|_|\__, | |____/ \__,_|\__\__,_| /_/   \_\_| |_|\__,_|_|\__, |\__|_|\___|___/
                 |___/                                                |___/

       Copyright (c) 2018 Sebastien Varrette <Sebastien.Varrette@uni.lu>

# Tutorial "Big Data Analytics"

This repository hosts documents, material and information related to the tutorial "__Big Data Analytics__" given during the [3rd NESUS Winter School and PhD Symposium](http://nesusws.irb.hr/) on Data Science and Heterogeneous Computing

* __Date__: Tuesday January 23th, 2018, 9h -- 13h.
* __Location__: Zagreb, Croatia
* _by_: Dr. [Sebastien Varrette](https://varrette.gforge.uni.lu/)

[![](https://github.com/Falkor/tutorials-BD-ML/raw/master/docs/cover.png)](https://github.com/Falkor/tutorials-BD-ML/raw/master/docs/slides_BDA.pdf)

## Installation / Repository Setup

Reference instructions can be found in [`docs/setup/install.md`](docs/setup/install.md).

This repository is hosted on [Github](https://github.com/Falkor/tutorials-BD-ML).

* To clone this repository, proceed as follows (adapt accordingly):

        $> mkdir -p ~/git/github.com/Falkor
        $> cd ~/git/github.com/Falkor
        $> git clone https://github.com/Falkor/tutorials-BD-ML.git

**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running:

    $> cd tutorials-BD-ML
    $> make setup

This will initiate the [Git submodules of this repository](.gitmodules) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

Later on, you can upgrade the [Git submodules](.gitmodules) to the latest version by running:

    $> make upgrade

If upon pulling the repository, you end in a state where another collaborator have upgraded the Git submodules for this repository, you'll end in a dirty state (as reported by modifications within the `.submodules/` directory). In that case, just after the pull, you **have to run** the following to ensure consistency with regards the Git submodules:

    $> make update

## Tutorial Slides and Instructions

The latest version of the tutorial is available online:

<http://nesusws-tutorials-bd-dl.rtfd.io>


## Issues / Feature request

You can submit bug / issues / feature request using the [`Falkor/tutorials-bd-ml` Project Tracker](https://github.com/Falkor/tutorials-BD-ML/issues)

## Licence

This project is released under the terms of the [GPL-3.0](LICENCE) licence.

[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](http://www.gnu.org/licenses/gpl-3.0.html)
