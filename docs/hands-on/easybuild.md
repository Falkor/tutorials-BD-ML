
# Hands-on: Building [custom] software with EasyBuild on HPC platforms

_Disclaimer_: this hands-on is adapted from the [tutorial on Easybuild](http://ulhpc-tutorials.readthedocs.io/en/latest/advanced/EasyBuild/) we provide at the [UL HPC School](http://ulhpc-tutorials.readthedocs.io/).


The objective of this hands-on is to demonstrate how [EasyBuild](https://github.com/easybuilders/easybuild) can be used to ease, automate and script the build of the software we will use in this tutorial.

Indeed, as researchers involved in many cutting-edge and hot topics, you probably have access to many theoretical resources to understand the surrounding concepts. Yet it should _normally_ give you a wish to test the corresponding software.
Traditionally, this part is rather time-consuming and frustrating, especially when the developers did not rely on a "regular" building framework such as [CMake](https://cmake.org/) or the [autotools](https://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html) (_i.e._ with build instructions as `configure --prefix <path> && make && make install`).

And when it comes to have a build adapted to an HPC system, you are somehow _forced_ to make a custom build performed on the target machine to ensure you will get the best possible performances. [EasyBuild](https://github.com/easybuilders/easybuild) is one approach to facilitate this step.
Also, later on, you probably want to recover a system configuration matching the detailed installation paths through a set of environmental variable  (Ex: `JAVA_HOME`, `HADOOP_HOME` etc...). At least you would like to see the traditional `PATH`, `CPATH` or `LD_LIBRARY_PATH` updated.

**Question**: what is the purpose of the above mentioned environmental variable?

For this second aspect, the solution came long time ago (in 1991) with the [Environment Modules](http://modules.sourceforge.net/).
We will cover it in the first part of this hands-on. Then, another advantage of [EasyBuild](https://github.com/easybuilders/easybuild) comes into account that justifies its wide-spread deployment across many HPC centers (incl. [UL HPC](http://hpc.uni.lu)): it has been designed to not only build any piece of software, but also to generate the corresponding module files to facilitate further interactions with it.
Thus we will cover [EasyBuild](https://github.com/easybuilders/easybuild) in the second part of this hands-on.



## Part 1: Environment modules and LMod

[Environment Modules](http://modules.sourceforge.net/) are a standard and well-established technology across HPC sites, to permit developing and using complex software and libraries builds with dependencies, allowing multiple versions of software stacks and combinations thereof to co-exist.

The tool in itself is used to manage environment variables such as `PATH`, `LD_LIBRARY_PATH` and `MANPATH`, enabling the easy loading and unloading of application/library profiles and their dependencies.

| Command                        | Description                                                   |
|--------------------------------|---------------------------------------------------------------|
| `module avail`                 | Lists all the modules which are available to be loaded        |
| `module spider <pattern>`      | Search for <pattern> among available modules **(Lmod only)**  |
| `module load <mod1> [mod2...]` | Load a module                                                 |
| `module unload <module>`       | Unload a module                                               |
| `module list`                  | List loaded modules                                           |
| `module purge`                 | Unload all modules (purge)                                    |
| `module display <module>`      | Display what a module does                                    |
| `module use <path>`            | Prepend the directory to the MODULEPATH environment variable  |
| `module unuse <path>`          | Remove the directory from the MODULEPATH environment variable |


*Note:* for more information, see the reference man pages for [modules](http://modules.sourceforge.net/man/module.html) and [modulefile](http://modules.sourceforge.net/man/modulefile.html), or the [official FAQ](http://sourceforge.net/p/modules/wiki/FAQ/).
You can also see our [modules page](https://hpc.uni.lu/users/docs/modules.html) on the [UL HPC website](http://hpc.uni.lu/users/).

At the heart of environment modules interaction resides the following components:

* the `MODULEPATH` environment variable, which defined the list of searched directories for modulefiles
* `modulefile` (see [an example](http://www.nersc.gov/assets/modulefile-example.txt)) associated to each available software.

Then, [Lmod](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod)  is a [Lua](http://www.lua.org/) based module system that easily handles the `MODULEPATH` Hierarchical problem.

Lmod is a new implementation of Environment Modules that easily handles the MODULEPATH Hierarchical problem. It is drop-in replacement for TCL/C modules and reads TCL modulefiles directly.
In particular, Lmod add many interesting features on top of the traditional implementation focusing on an easier interaction (search, load etc.) for the users. Thus that's the tool I would advise to deploy.

* [User guide](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod/user-guide)
* [Advanced user guide](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod/advanced-user-guide)
* [Sysadmins Guide](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod/system-administrators-guide)

The Vagrant box deployed in this project already pre-installed [Environment Modules](http://modules.sourceforge.net/) and [Lmod](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod)   (see [`vagrant/bootstrap.sh`](https://github.com/Falkor/tutorials-BD-ML/blob/master/vagrant/bootstrap.sh)). __Try it now__:

```bash
$> vagrant ssh      # Or 'vagrant ssh default'
$> module -h
$> echo $MODULEPATH
/etc/modulefiles:/usr/share/modulefiles:/usr/share/modulefiles/Linux:/usr/share/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core
```

For the moment, there are very few modules available:

```bash
$> module avail       # OR 'module av'

-------------------- /usr/share/lmod/lmod/modulefiles/Core --------------------
   lmod/6.5.1    settarg/6.5.1

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```

We are going to complete the list with Easybuild.

## Part 2: Easybuild

[<img width='150px' src='http://easybuild.readthedocs.io/en/latest/_static/easybuild_logo_alpha.png'/>](https://easybuilders.github.io/easybuild/)

EasyBuild is a tool that allows to perform automated and reproducible compilation and installation of software. A large number of scientific software are supported (1411 software packages in the last release 3.5.1) -- see also [What is EasyBuild?](http://easybuild.readthedocs.io/en/latest/Introduction.html)


All builds and installations are performed at user level, so you don't need the admin rights.
The software are installed in your home directory (by default in `$HOME/.local/easybuild/software/`) and a module file is generated (by default in `$HOME/.local/easybuild/modules/`) to use the software.

EasyBuild relies on two main concepts: *Toolchains* and *EasyConfig file*.

A **toolchain** corresponds to a compiler and a set of libraries which are commonly used to build a software. The two main toolchains frequently used on the UL HPC platform are the GOOLF and the ICTCE toolchains. GOOLF is based on the GCC compiler and on open-source libraries (OpenMPI, OpenBLAS, etc.). ICTCE is based on the Intel compiler and on Intel libraries (Intel MPI, Intel Math Kernel Library, etc.).

An **EasyConfig file** is a simple text file that describes the build process of a software. For most software that uses standard procedure (like `configure`, `make` and `make install`), this file is very simple. Many EasyConfig files are already provided with EasyBuild.
By default, EasyConfig files and generated modules are named using the following convention:
`<Software-Name>-<Software-Version>-<Toolchain-Name>-<Toolchain-Version>`.
However, it is a good practice to use a **hierarchical** approach where the software are classified under a category (or class).
Thus we are going to use this convention (see below the `CategorizedModuleNamingScheme` option for the `EASYBUILD_MODULE_NAMING_SCHEME` environmental variable), meaning that the layout will respect the following hierarchy:
`<Software-Class>/<Software-Name>/<Software-Version>-<Toolchain-Name>-<Toolchain-Version>`

Additional details are available on EasyBuild website:

- [EasyBuild homepage](https://easybuilders.github.io/easybuild/)
- [EasyBuild documentation](http://easybuild.readthedocs.io/)
- [What is EasyBuild?](http://easybuild.readthedocs.io/en/latest/Introduction.html)
- [Toolchains](https://github.com/easybuilders/easybuild/wiki/Compiler-toolchains)
- [EasyConfig files](http://easybuild.readthedocs.io/en/latest/Writing_easyconfig_files.html)
- [List of supported software packages](http://easybuild.readthedocs.io/en/latest/version-specific/Supported_software.html)

### a. Installation.

Again, [EasyBuild](http://easybuild.readthedocs.io/) comes pre-installed in your vagrant box.
However, it can be reinstalled without any problem (actually that's how you can update it upon new releases of the tool) so we are going to do it now -- see also [the official instructions](http://easybuild.readthedocs.io/en/latest/Installation.html).

```bash
$> vagrant ssh    # Or 'vagrant ssh default', if not yet done
$> cat /etc/profile.d/easybuild.sh    # Set upon 'vagrant provision'
```

What is important for the installation of Easybuild are the following variables:

* `EASYBUILD_PREFIX`: where to install **local** modules and software, _i.e._ `$HOME/.local/easybuild`
* `EASYBUILD_MODULES_TOOL`, the type of [modules](http://modules.sourceforge.net/) tool you are using, _i.e._ `LMod` in this case
* `EASYBUILD_MODULE_NAMING_SCHEME`, the way the software and modules should be organized (flat view or hierarchical) -- we're advising on `CategorizedModuleNamingScheme`.

Check that these variables are defined:

```bash
$> echo $EASYBUILD_PREFIX
$> echo $EASYBUILD_MODULES_TOOL
$> echo $EASYBUILD_MODULE_NAMING_SCHEME
```

If they are not set, just `source /etc/profile.d/easybuild.sh` and check again.

Now you are safe to install it:

```bash
# download installation script
$> curl -o /tmp/bootstrap_eb.py  https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py

# install Easybuild
$> python /tmp/bootstrap_eb.py $EASYBUILD_PREFIX
```

If you're lazy to type all these commands, just run the installer script made for you:

```bash
$> /vagrant/resources/easybuild/bootstrap.sh
```

Now you can use your freshly built software:

```bash
$> eb --version             # expected ;)
-bash: eb: command not found

# Load the newly installed Easybuild
$> echo $MODULEPATH
/etc/modulefiles:/usr/share/modulefiles:/usr/share/modulefiles/Linux:/usr/share/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core

$> module use $LOCAL_MODULES
$> echo $MODULEPATH
/home/vagrant/.local/easybuild/modules/all:/etc/modulefiles:/usr/share/modulefiles:/usr/share/modulefiles/Linux:/usr/share/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core

$> module spider Easybuild
$> module load tools/EasyBuild
$> eb --version
eb --version
This is EasyBuild 3.5.1 (framework: 3.5.1, easyblocks: 3.5.1) on host node-1.vagrant.dev

```

Since we are going to use these command quite often, an alias `mu` is provided and can be used from now on. Use it **now**

```
$> mu
$> module avail     # OR 'ma'
```

### b. Local vs. Global Usage

As you probably guessed from `/etc/profile.d/easybuild.sh`, we are going to use two places for the installed software:

* local to each VM in `~/.local/easybuild`          (see `$LOCAL_MODULES`)
* global _i.e._ shared with other VMs in `/opt/apps` (see `$GLOBAL_MODULES`) -- see the target of the symlink.

Default usage (with the `eb` command) would install your software and modules in `~/.local/easybuild`.
For deployment within the global area for further shares (_i.e._ in `/opt/apps`) as for Java, Hadoop and Spark we are going to use in this tutorial, you probably want to favor this approach to avoid redoing it on all VMs.
As a matter of convenience, the alias `global_eb` is provided to you when you want to place builds in the global space.

Before that, let's explore the basic usage of [EasyBuild](http://easybuild.readthedocs.io/) and the `eb` command

```bash
# Search for an Easybuild recipY with 'eb -S <pattern>'
$> eb -S Spark
CFGS1=/home/vagrant/.local/easybuild/software/tools/EasyBuild/3.5.1/lib/python2.7/site-packages/easybuild_easyconfigs-3.5.1-py2.7.egg/easybuild/easyconfigs/s/Spark
 * $CFGS1/Spark-1.3.0.eb
 * $CFGS1/Spark-1.4.1.eb
 * $CFGS1/Spark-1.5.0.eb
 * $CFGS1/Spark-1.6.0.eb
 * $CFGS1/Spark-1.6.1.eb
 * $CFGS1/Spark-2.0.0.eb
 * $CFGS1/Spark-2.0.2.eb
 * $CFGS1/Spark-2.2.0-Hadoop-2.6-Java-1.8.0_144.eb
 * $CFGS1/Spark-2.2.0-Hadoop-2.6-Java-1.8.0_152.eb
 * $CFGS1/Spark-2.2.0-intel-2017b-Hadoop-2.6-Java-1.8.0_152-Python-3.6.3.eb
```

As mentioned above, Easybuild reciPY for a given software comes under the form of a single `.eb` file (easyconfig).
We'll install Spark in due time, for now let's demonstrate the installation of a simple software -- first locally ([zlib](https://zlib.net/)) then globally ([snappy](https://github.com/google/snappy) and [protobuf](https://github.com/google/protobuf):

```bash
# Seach for zlib
$> eb -S zlib
```
Pick one recipY (for instance zlib-1.2.8.eb), install it with 'eb <name>.eb [-D] -r'

* `-D` enables the dry-run mode to check what's going to be install -- **ALWAYS try it first**
* `-r` enables the robot mode to automatically insatall all dependencies while searching for easyconfigs in a set of pre-defined directories -- you can also prepend new directories to search for eb files (like the current directory `$PWD`) using the option and syntax `--robot-paths=$PWD:` (do not forget the ':'). See [Controlling the robot search path documentation](http://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html#controlling-the-robot-search-path)

So let's install `zlib` version 1.2.8:

```bash
$> eb zlib-1.2.8.eb -Dr    # Dry-run mode
[...]
 * [ ] $CFGS/zlib-1.2.8.eb (module: lib/zlib/1.2.8)
```

As can be seen, there is a single element to installed and this has not been done so far (box not checked).
Let's really install it:

```bash
$> eb zlib-1.2.8.eb -r
[...]
== COMPLETED: Installation ended successfully
```

Check the installed software:

```bash
$> module avail

-------------- /home/vagrant/.local/easybuild/modules/all --------------
   lib/zlib/1.2.8    tools/EasyBuild/3.5.1 (L)

-------------------- /usr/share/lmod/lmod/modulefiles/Core --------------------
   lmod/6.5.1    settarg/6.5.1

  Where:
   L:  Module is loaded

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".

$> module show lib/zlib
$> module load lib/zlib
$> module list          # OR 'ml'
```

Let's repeat the process globally for [snappy](https://github.com/google/snappy) **version 1.1.6** (the version is important), the fast compressor/decompressor from Google, and [protobuf](https://github.com/google/protobuf), Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data (**version 2.5.0**) we'll need later:

```bash
# Search for snappy
$> eb -S snappy
CFGS1=/home/vagrant/.local/easybuild/software/tools/EasyBuild/3.5.1/lib/python2.7/site-packages/easybuild_easyconfigs-3.5.1-py2.7.egg/easybuild/easyconfigs/s/snappy
 * $CFGS1/snappy-1.1.2-GCC-4.9.2.eb
 * $CFGS1/snappy-1.1.3-GCC-4.9.3-2.25.eb
 * $CFGS1/snappy-1.1.3-GCC-4.9.3.eb
 * $CFGS1/snappy-1.1.6.eb
 * $CFGS1/snappy-1.1.7-intel-2017a.eb

# Install globaly -- equivalent of 'eb --installpath=/opt/apps <name>.eb [...]
$> global_eb snappy-1.1.6.eb -Dr    # Dry run
[...]
 * [ ] $CFGS/c/CMake/CMake-3.9.1.eb (module: devel/CMake/3.9.1)
 * [ ] $CFGS/s/snappy/snappy-1.1.6.eb (module: lib/snappy/1.1.6)

# This time, there are one dependency not yet satistfied.
# Let's build all of them -- /!\ DO IT GLOBALLY
$> global_eb snappy-1.1.6.eb -r
```

Repeat with [protobuf](https://github.com/google/protobuf), Google's data interchange format:

```bash
$> eb -S protobuf    # Search for protobuf
$> global_eb protobuf-2.5.0.eb -Dr    # Dry-run
$> global_eb protobuf-2.5.0.eb -r
```

Check the resulting state:

```bash
$> module avail

-------------- /home/vagrant/.local/easybuild/modules/all --------------
   lib/zlib/1.2.8    tools/EasyBuild/3.5.1 (L)

------------------------ /opt/apps/modules/all -------------------------
devel/CMake/3.9.1    devel/protobuf/2.5.0    lib/snappy/1.1.6

-------------------- /usr/share/lmod/lmod/modulefiles/Core --------------------
   lmod/6.5.1    settarg/6.5.1

  Where:
   L:  Module is loaded

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```
