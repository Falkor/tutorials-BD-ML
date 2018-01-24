
We are going to install the  [Hadoop MapReduce by Cloudera](https://www.cloudera.com/downloads/cdh/5-12-0.html) using [EasyBuild](http://easybuild.readthedocs.io/).

As this involves Java (something more probably HPC users don't like), and that Java needs to be treated specifically within Easybuild do to the licences involved, we will now cover it.

**IMPORTANT**:you need to have followed the [Easybuild hand-on](../easybuild.md) before reaching this place.

## Step 1. Pre-requisite

### 1.a. Java 7u80 and 8u152

We'll need several version of the [JDK](http://www.oracle.com/technetwork/java/javase/overview/index.html) (in Linux x64 source mode i.e. `jdk-<version>-linux-x64.tar.gz`), more specifically 1.7.0_80 (aka `7u80` in Oracle's naming convention) and 1.8.0_152 (aka `8u152`).

Let's first try the classical approach we experimented before:

```bash
$> vagrant ssh    # Or 'vagrant ssh default', if not yet done
$> mu
$> module av      # or 'module available' or 'ma'

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

Let's search for Java and install it:

```
$> eb -S Java
[...]
$> eb -S Java | grep '/Java-'  # You want this filter ;)
$> eb Java-1.7.0_80.eb -Dr     # Dry-run
[...]
 * [ ] $CFGS/Java-1.7.0_80.eb (module: lang/Java/1.7.0_80)

$> eb Java-1.7.0_80.eb -r
[...]
== FAILED: Installation ended unsuccessfully
   build failed: Couldn't find file jdk-7u80-linux-x64.tar.gz anywhere, and downloading it didn't work either...
[...]
```

As the error indicates, you first need to download the archive.
Hopefully, you can get it as follows:

```bash
$> cd /vagrant/resources/java/
$> make       # OR make fetch
[...]
==> Downloading Java 7 archive 'jdk-7u80-linux-x64.tar.gz'
[...]
==> Downloading Java 8 archive 'jdk-8u152-linux-x64.tar.gz'
```
 Now that you have the archive, you can instruct Easybuild to use them to build the Java modules -- we'll do it globally with `eb --installpath=/opt/apps/` (or `global_eb` for short as per alias definition in `/etc/profile.d/easybuild.sh`):

```
$> global_eb Java-1.7.0_80.eb -Dr  # Dry-run
$> global_eb Java-1.7.0_80.eb -r

$> global_eb Java-1.8.0_152.eb -Dr # Dry-run
$> global_eb Java-1.8.0_152.eb -r
```

Check the result:

```bash
$> module av      # or 'module available' or 'ma'

-------------- /home/vagrant/.local/easybuild/modules/all --------------
   lib/zlib/1.2.8    tools/EasyBuild/3.5.1 (L)

------------------------ /opt/apps/modules/all -------------------------
  devel/CMake/3.9.1    devel/protobuf/2.5.0    lang/Java/1.7.0_80
  lang/Java/1.8.0_152   lib/snappy/1.1.6

devel/CMake/3.9.1    devel/protobuf/2.5.0    lib/snappy/1.1.6

-------------------- /usr/share/lmod/lmod/modulefiles/Core --------------------
   lmod/6.5.1    settarg/6.5.1

  Where:
   L:  Module is loaded

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".

$> module show lang/Java/1.7.0_80
--------------------------------------------------------------------------------------------
   /opt/apps/modules/all/lang/Java/1.7.0_80.lua:
-------------------------------------------------------------------------------------------
help([[
Description
===========
Java Platform, Standard Edition (Java SE) lets you develop and deploy
 Java applications on desktops and servers.


More information
================
 - Homepage: http://java.com/
]])
whatis("Description: Java Platform, Standard Edition (Java SE) lets you develop and deploy
 Java applications on desktops and servers.")
whatis("Homepage: http://java.com/")
conflict("lang/Java")
prepend_path("CPATH","/opt/apps/software/lang/Java/1.7.0_80/include")
prepend_path("LD_LIBRARY_PATH","/opt/apps/software/lang/Java/1.7.0_80/lib")
prepend_path("LIBRARY_PATH","/opt/apps/software/lang/Java/1.7.0_80/lib")
prepend_path("MANPATH","/opt/apps/software/lang/Java/1.7.0_80/man")
prepend_path("PATH","/opt/apps/software/lang/Java/1.7.0_80/bin")
setenv("EBROOTJAVA","/opt/apps/software/lang/Java/1.7.0_80")
setenv("EBVERSIONJAVA","1.7.0_80")
setenv("EBDEVELJAVA","/opt/apps/software/lang/Java/1.7.0_80/easybuild/lang-Java-1.7.0_80-easybuild-devel")
prepend_path("PATH","/opt/apps/software/lang/Java/1.7.0_80")
setenv("JAVA_HOME","/opt/apps/software/lang/Java/1.7.0_80")
```


### 1.b Maven 3.5.2

We will also need an updated version of [Maven](https://maven.apache.org/) (3.5.2).

Let's first try with the default reciPy:

```bash
$> eb -S Maven
[...]
 * $CFGS/Maven-3.2.3.eb
 * $CFGS/Maven-3.3.3.eb
 * $CFGS/Maven-3.3.9.eb
 * $CFGS/Maven-3.5.0.eb

# Let's try to install the most recent one:
$> eb Maven-3.5.0.eb -Dr
[...]
 * [ ] $CFGS/Maven-3.5.0.eb (module: devel/Maven/3.5.0)
$> eb Maven-3.5.0.eb -r
[...]
== FAILED: Installation ended unsuccessfully
== Results of the build can be found in the log file(s) /tmp/eb-KHJSrE/easybuild-Maven-3.5.0-20180122.110520.UPvji.log

# Let's see the end of the logs:
$> tail /tmp/eb-KHJSrE/easybuild-Maven-3.5.0-20180122.110520.UPvji.log
```

As can be seen, there was an issue to get the archive file `apache-maven-3.5.0-bin.tar.gz`.

Normally that's where you should copy the failing easyconfigs and patch it (ideally toward the latest version available with the appropriate link and checksum) to correct it, and submit it to the community via [pull-requests to the `easybuild-easyconfigs` issue tracker](https://github.com/easybuilders/easybuild-easyconfigs/blob/master/CONTRIBUTING.md).
Since 3.5.2 is the latest release, that would mean the following actions:

```
$> eb -S Maven
CFGS=<path>
 * $CFGS/Maven-3.2.3.eb
 * $CFGS/Maven-3.3.3.eb
 * $CFGS/Maven-3.3.9.eb
 * $CFGS/Maven-3.5.0.eb

# Declare the CFGS variable as above
$> CFGS=<path>    # /!\ ADAPT <path> accordingly
$> cp $CFGS/Maven-3.5.0.eb   Maven-3.5.2.eb
```

Adapt it as follows:


```diff
$> diff -ru $CFGS//Maven-3.5.0.eb Maven-3.5.2.eb
--- /home/vagrant/.local/easybuild/software/tools/EasyBuild/3.5.1/lib/python2.7/site-packages/easybuild_easyconfigs-3.5.1-py2.7.egg/easybuild/easyconfigs/m/Maven/Maven-3.5.0.eb     2018-01-18 10:56:18.396697000 +0100
+++ Maven-3.5.2.eb      2018-01-18 12:13:39.699872000 +0100
@@ -1,7 +1,7 @@
 easyblock = 'PackedBinary'

 name = 'Maven'
-version = '3.5.0'
+version = '3.5.2'

 homepage = 'http://maven.apache.org/index.html'
 description = """Binary maven install, Apache Maven is a software project management and comprehension tool. Based on
@@ -13,7 +13,10 @@

 sources = ['apache-maven-%(version)s-bin.tar.gz']
 source_urls = ['http://apache.org/dist/maven/maven-%(version_major)s/%(version)s/binaries/']
-checksums = ['beb91419245395bd69a4a6edad5ca3ec1a8b64e41457672dc687c173a495f034']
+checksums = ['707b1f6e390a65bde4af4cdaf2a24d45fc19a6ded00fff02e91626e3e42ceaff']
+
+dependencies = [('Java', '1.7.0_80')]
+

 sanity_check_paths = {
     'files': ['bin/mvn'],
```

Luckily for you, the resulting easyconfigs is provided to you in `/vagrant/resources/java`

Install it globally (_i.e._ with `eb --installpath=/opt/apps/ [...]` or `global_eb`):

```
$> cd /vagrant/resources/java
$> global_eb ./Maven-3.5.2.eb -Dr   # Dry-run
$> global_eb ./Maven-3.5.2.eb -r
```


Check the result:

```bash
$> module av      # or 'module available' or 'ma'

-------------- /home/vagrant/.local/easybuild/modules/all --------------
   lib/zlib/1.2.8    tools/EasyBuild/3.5.1 (L)

------------------------ /opt/apps/modules/all -------------------------
  devel/CMake/3.9.1    devel/Maven/3.5.2     devel/protobuf/2.5.0
  lang/Java/1.7.0_80   lang/Java/1.8.0_152   lib/snappy/1.1.6

-------------------- /usr/share/lmod/lmod/modulefiles/Core --------------------
   lmod/6.5.1    settarg/6.5.1

  Where:
   L:  Module is loaded
```


## Step 2. Hadoop Installation

We're going to install the most recent  [Hadoop by Cloudera](https://www.cloudera.com/downloads/cdh/5-12-0.html) _i.e._ `Hadoop-2.6.0-cdh5.12.0-native.eb`.

```bash
$> eb -S Hadoop | grep cdh
 * $CFGS1/h/Hadoop/Hadoop-2.5.0-cdh5.3.1-native.eb
 * $CFGS1/h/Hadoop/Hadoop-2.6.0-cdh5.12.0-native.eb
 * $CFGS1/h/Hadoop/Hadoop-2.6.0-cdh5.4.5-native.eb
 * $CFGS1/h/Hadoop/Hadoop-2.6.0-cdh5.7.0-native.eb
 * $CFGS1/h/Hadoop/Hadoop-2.6.0-cdh5.8.0-native.eb
```

We'll just need to adapt the recipY to use the latest Maven we just installed.

```diff
--- /home/vagrant/.local/easybuild/software/tools/EasyBuild/3.5.1/lib/python2.7/site-packages/easybuild_easyconfigs-3.5.1-py2.7.egg/easybuild/easyconfigs/h/Hadoop/Hadoop-2.6.0-cdh5.12.0-native.eb	2018-01-21 08:02:07.814526419 +0000
+++ Hadoop-2.6.0-cdh5.12.0-native.eb	2018-01-22 11:40:23.618576847 +0000
@@ -14,7 +14,7 @@
 patches = ['Hadoop-TeraSort-on-local-filesystem.patch']

 builddependencies = [
-    ('Maven', '3.5.0'),
+    ('Maven', '3.5.2'),
     ('protobuf', '2.5.0'),  # *must* be this version
     ('CMake', '3.9.1'),
     ('snappy', '1.1.6'),

```

The resulting Easyconfigs is provided to you in `/vagrant/resources/hadoop`:
Load the modules required for the build:

```
$> module load devel/Maven devel/protobuf devel/CMake lib/snappy
```

And build it globally (_i.e._ with `eb --installpath=/opt/apps/ [...]` or `global_eb`).
Note that we will need to inform Easybuild about the directory where the special easyconfigs `Maven-3.5.2.eb` resides _i.e._ `/vagrant/resources/java`.
As per [documentation](http://easybuild.readthedocs.io/en/latest/Using_the_EasyBuild_command_line.html?highlight=EASYBUILD_ROBOT#prepending-and-or-appending-to-the-default-robot-search-path), this can be done by prepending this directory to the default robot search path, either with `--robot-paths=<dir>:` (don't forgher the last ':') or the `EASYBUILD_ROBOT_PATHS` variable.

```
$> export EASYBUILD_ROBOT_PATHS=$(find /vagrant/resources/ -name *.eb | xargs dirname | sort | uniq | xargs echo | tr ' ' ':'):


$> cd /vagrant/resources/hadoop

# (Optional - NOT recommanded) if you don't want to play with --robot-paths
$> export EASYBUILD_ROBOT_PATHS=$(find /vagrant/resources/ -name *.eb | xargs dirname | sort | uniq | xargs echo | tr ' ' ':'):
$> global_eb ./Hadoop-2.6.0-cdh5.12.0-native.eb -D  # Dry-run
$> global_eb ./Hadoop-2.6.0-cdh5.12.0-native.eb

# OR (recommended)
$> global_eb ./Hadoop-2.6.0-cdh5.12.0-native.eb --robot-path=$PWD:/vagrant/resources/java: -D # Dry-run
$> global_eb ./Hadoop-2.6.0-cdh5.12.0-native.eb --robot-path=$PWD:/vagrant/resources/java:
```

**`/!\ IMPORTANT`: The build is quite long -- it takes ~30 minutes on 4 cores**
