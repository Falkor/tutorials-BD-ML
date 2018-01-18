First of all, ensure you have install the [Pre-requisites / Preliminary software](preliminaries.md) and follow the corresponding configuration.

Then this repository is hosted on [Github](https://github.com/Falkor/tutorials-BD-ML). Assuming you have installed `git`:

* To clone this repository, proceed as follows (adapt accordingly):

        $> mkdir -p ~/git/github.com/Falkor
        $> cd ~/git/github.com/Falkor
        $> git clone git@github.com:Falkor/tutorials-BD-ML.git

* You'll probably wish to have a separate directory structure when working in this tutorial. Here is a suggested approach:

        $> mkdir -p ~/tutorials/NESUS-WS/BD-ML
        $> cd ~/tutorials/NESUS-WS/BD-ML
        $> ln -s ~/git/github.com/Falkor/tutorials-BD-ML ref.d

**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running:

    $> cd ~/git/github.com/Falkor/tutorials-BD-ML
    $> make setup

This will initiate the [Git submodules of this repository](.gitmodules) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

Later on, you can upgrade the [Git submodules](.gitmodules) to the latest version by running:

    $> make upgrade

If upon pulling the repository, you end in a state where another collaborator have upgraded the Git submodules for this repository, you'll end in a dirty state (as reported by modifications within the `.submodules/` directory). In that case, just after the pull, you **have to run** the following to ensure consistency with regards the Git submodules:

    $> make update
