
**IMPORTANT**: you should have installed [Hadoop MapReduce by Cloudera](https://www.cloudera.com/downloads/cdh/5-12-0.html) using [EasyBuild](http://easybuild.readthedocs.io/) as detailed in the [Hands-on 2](/hands-on/hadoop/install/).


## Step 1 Single mode

```bash
$> vagrant ssh default
(vm)$> mu
(vm)$> module load tools/Hadoop
(vm)$> module list

Currently Loaded Modules:
  1) tools/EasyBuild/3.5.1   2) lang/Java/1.7.0_80   3) devel/Maven/3.5.2   4) devel/protobuf/2.5.0   5) devel/CMake/3.9.1   6) lib/snappy/1.1.6   7) tools/Hadoop/2.6.0-cdh5.12.0-native


(vm)$> module show tools/Hadoop
------------------------------------------------------------------------
   /opt/apps/modules/all/tools/Hadoop/2.6.0-cdh5.12.0-native.lua:
------------------------------------------------------------------------
help([[
Description
===========
Hadoop MapReduce by Cloudera


More information
================
 - Homepage: http://archive.cloudera.com/cdh5/cdh/5/
]])
whatis("Description: Hadoop MapReduce by Cloudera")
whatis("Homepage: http://archive.cloudera.com/cdh5/cdh/5/")
conflict("tools/Hadoop")
load("lang/Java/1.7.0_80")
load("devel/Maven/3.5.2")
load("devel/protobuf/2.5.0")
load("devel/CMake/3.9.1")
load("lib/snappy/1.1.6")
prepend_path("CPATH","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/include")
prepend_path("LD_LIBRARY_PATH","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/lib")
prepend_path("LIBRARY_PATH","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/lib")
prepend_path("PATH","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/bin")
prepend_path("PATH","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/sbin")
setenv("EBROOTHADOOP","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native")
setenv("EBVERSIONHADOOP","2.6.0-cdh5.12.0")
setenv("EBDEVELHADOOP","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/easybuild/tools-Hadoop-2.6.0-cdh5.12.0-native-easybuild-devel")
prepend_path("HADOOP_HOME","/opt/apps/software/tools/Hadoop/2.6.0-cdh5.12.0-native/share/hadoop/mapreduce")
```

Now you can follow the [official tutorial](https://hadoop.apache.org/docs/r2.6.0/hadoop-project-dist/hadoop-common/SingleCluster.html) to ensure you are running in **Single Node Cluster**

Once this is done, follow the [official Wordcount instructions](https://hadoop.apache.org/docs/r2.6.0/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html#Example:_WordCount_v1.0)



## b. Distributed mode

Adapt the configuration to enable a [Cluster Setup](https://hadoop.apache.org/docs/r2.6.0/hadoop-project-dist/hadoop-common/ClusterSetup.html)
