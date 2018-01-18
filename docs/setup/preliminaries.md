
`/!\ IMPORTANT`: this is a **hands-on** tutorial: participants are expected bring a laptop and pre-install software _in advance_ to make the best use of time during the tutorial.
If for some reason you are unable to fulfill this pre-requisite, try to seat close to an attendee that is able to perform these tasks.

_Note_: in the following instructions, terminal commands are prefixed by a virtual prompt `$>`which obviously **does not** belong to the command.

### Online accounts

Kindly create in advance the various accounts for the **cloud services** we might use, _i.e._:

* [Github](https://github.com/):
* [Vagrant Cloud](https://vagrantcloud.com/)
* [Docker Hub](https://hub.docker.com/)

### Software

Install the following software, depending on your running platform:

| Platform      | Software                                                                                       | Description                           | Usage                   |
|---------------|------------------------------------------------------------------------------------------------|---------------------------------------|-------------------------|
| Mac OS        | [Homebrew](http://brew.sh/)                                                                    | The missing package manager for macOS | `brew install ...`      |
| Mac OS        | [Brew Cask Plugin](https://caskroom.github.io)                                                 | Mac OS Apps install made easy         | `brew cask install ...` |
| Mac OS        | [iTerm2](https://www.iterm2.com/)                                                              | _(optional)_ enhanced Terminal        |                         |
| Windows       | [MobaXTERM](https://mobaxterm.mobatek.net/)                                                    | Terminal with tabbed SSH client       |                         |
| Windows       | [Git for Windows](https://git-for-windows.github.io/)                                          | I'm sure you guessed                  |                         |
| Windows       | [SourceTree](https://www.sourcetreeapp.com/)                                                   | _(optional)_ enhanced git GUI         |                         |
| Windows/Linux | [Virtual Box](https://www.virtualbox.org/)                                                     | Free hypervisor provider for Vagrant  |                         |
| Windows/Linux | [Vagrant](https://www.vagrantup.com/downloads.html)                                            | Reproducible environments made easy.  |                         |
| Linux         | Docker for [Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)       | Lightweight Reproducible Containers   |                         |
| Windows       | [Docker for Windows](https://docs.docker.com/engine/installation/windows/#/docker-for-windows) | Lightweight Reproducible Containers   |                         |

Follow the below **custom** instructions depending on your running platform and Operating System

#### Mac OS X

Once you have [Homebrew](http://brew.sh/) installed:

~~~bash
$> brew install git-core git-flow    # (newer) Git stuff
$> brew install mkdocs               # (optional) install mkdocs
$> brew install pyenv pyenv-virtualenv direnv # see https://varrette.gforge.uni.lu/tutorials/pyenv.html
$> brew tap caskroom/cask            # install brew cask  -- see https://caskroom.github.io/
$> brew cask install virtualbox      # install virtualbox -- see https://www.virtualbox.org/
$> brew cask install vagrant         # install Vagrant    -- see https://www.vagrantup.com/downloads.html
$> brew cask install vagrant-manager # see http://vagrantmanager.com/
$> brew cask install docker          # install Docker -- https://docs.docker.com/engine/installation/mac/
~~~

_Note_: later on, you might wish to use the following shell function to update the software installed using [Homebrew](http://brew.sh/).

```bash
bup () {
	echo "Updating your [Homebrew] system"
	brew update
	brew upgrade
	brew cu
	brew cleanup
	brew cask cleanup
}
```

#### Linux (Debian / Ubuntu)

~~~bash
# Adapt the package names (and package manager) in case you are using another Linux distribution.
$> sudo apt-get update
$> sudo apt-get install git git-flow build-essential
$> sudo apt-get install rubygems virtualbox vagrant virtualbox-dkms
~~~

For [Docker](https://docker.com/), choose your distribution from https://docs.docker.com/engine/installation/linux/
and follow the instructions.
You need a reasonably new kernel version (3.10 or higher).
Here are detailed instuctions per OS:

* [Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
* [Debian](https://docs.docker.com/engine/installation/linux/docker-ce/debian/)
* [CentOS](https://docs.docker.com/engine/installation/linux/docker-ce/centos/)


#### Windows

On Windows (10, 7/8 should also be OK) you should download and install the following tools:

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads), download the latest [VirtualBox installer](https://download.virtualbox.org/virtualbox/5.2.6/VirtualBox-5.2.6-120293-Win.exe) and [Extension pack](https://download.virtualbox.org/virtualbox/5.2.6/Oracle_VM_VirtualBox_Extension_Pack-5.2.6-120293.vbox-extpack).
    - First, install VirtualBox with the default settings. Note that a warning will be issued that your network connections will be temporarily impacted, you should continue.
    - Then, run the downloaded extension pack (.vbox-extpack file), it will open within the VirtualBox Manager and you should let it install normally.

* [Vagrant](https://www.vagrantup.com/downloads.html), download the latest [Vagrant installer](https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.msi)
    - Proceed with the installation, no changes are required to the default setup.

* [Git](https://git-scm.com/downloads), download the latest [Git installer](https://git-scm.com/download/win)

The Git installation requires a few changes to the defaults, make sure the following are selected in the installer:

   - Select Components: _Use a TrueType font in all console windows)_
   - Adjusting your PATH environment: _Use Git and optional Unix tools from the Windows Command Prompt_
   - Configuring the line ending conversions: _Checkout Windows-style, commit Unix-style line endings)_
   - Configuring the terminal emulator to use with Git Bash: _Use MinTTY (the default terminal of MSYS2)_
   - Configuring extra options: _Enable symbolic links_

Please note that to clone a Git repository which contains symbolic links (symlinks), you **must start a shell** (Microsoft PowerShell in this example, but a Command Prompt - cmd.exe - or Git Bash shell should work out fine) **with elevated (Administrator) privileges**. This is required in order for git to be able to create symlinks on Windows:

* Start Powershell:
    1. In the Windows Start menu, type PowerShell
    2. Normally PowerShell will appear as the first option on the top as **Best match**
    3. Right click on it and select "Run as administrator"

See also the instructions and screenshots provided on this [tutorial](http://rr-tutorials.readthedocs.io/en/latest/setup/#windows).

## Post-Installations checks

__Git__:

(Eventually) Make yourself known to Git

~~~bash
$> git config –-global user.name  "Firstname LastName"              # Adapt accordingly
$> git config –-global user.email "Firstname.LastName@domain.org"   # Adapt with your mail
~~~

Clone the [project repository on Github](https://github.com/Falkor/tutorials-BD-ML) from a Terminal (Powershell as `administrator` under windows):

~~~bash
$> mkdir -p ~/tutorials/NESUS-WS/BD-ML
$> mkdir -p ~/git/github.com/Falkor
# Clone reference git
$> cd ~/git/github.com/Falkor
$> git clone git@github.com:Falkor/tutorials-BD-ML.git
# (optional) symlink to git reference repo
$> cd ~/tutorials/NESUS-WS/BD-ML
$> ln -s ~/git/github.com/Falkor/tutorials-BD-ML ref.d
~~~

__Vagrant__

Ensure that vagrant is running and has the appropriate plugins from the command line

```bash
$> vagrant --version
Vagrant 2.0.1

# Install a couple of useful vagrant plugins:
# - https://github.com/oscar-stack/vagrant-hosts
# - https://github.com/dotless-de/vagrant-vbguest
# - https://github.com/emyl/vagrant-triggers
# - https://github.com/fgrehm/vagrant-cachier
# Terminal-table is a nice ruby gem for automatically print tables with nice layout
for p in vagrant-hosts vagrant-vbguest vagrant-triggers vagrant-cachier terminal-table; do \
    vagrant plugin install $p; \
done

# Install the default CentOS 7 box
$> vagrant init centos/7     # (optional) create a Vagrantfile with CentOS/7 base image
$> vagrant box update
```

__Docker__

Launch the `Docker` app and then check that the [Docker](https://www.docker.com/) works:

~~~bash
$> docker info
Containers: 9
 Running: 0
 Paused: 0
 Stopped: 9
Images: 12
Server Version: 17.09.1-ce
[...]
~~~

*  Pull the docker containers we will need for the second part of this tutorial

~~~bash
$> docker pull centos
~~~

* Login onto you [Docker hub account](https://hub.docker.com/) (take note of your Docker Hub ID and password).
    - With docker installed, run

~~~bash
$ docker login -u <your docker hub ID>
~~~
and enter your password.

Note that if the Docker installation fails, you can use <http://play-with-docker.com/> to try Docker, but **it won't work if all of us try it once!**
So use it only as a last resort, and it is up to you to use any important information (like the Docker hub account) inside it.
