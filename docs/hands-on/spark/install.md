
# Running Big Data Application using Apache Spark


[Apache Spark](http://spark.apache.org/docs/latest/) is a large-scale data processing engine that performs in-memory computing. Spark offers bindings in Java, Scala, Python and R for building parallel applications.
high-level APIs in Java, Scala, Python and R, and an optimized engine that supports general execution graphs. It also supports a rich set of higher-level tools including Spark SQL for SQL and structured data processing, MLlib for machine learning, GraphX for graph processing, and Spark Streaming.

In this tutorial, we are going to build [Apache Spark](http://spark.apache.org/) using [EasyBuild](http://easybuild.readthedocs.io/) and perform some basic checks.
You are free then to follow any online tutorial to apply the Spark framework over any relevant application for your domain.

**IMPORTANT**: Ensure you have completed successfully all precedent hands-on, in particular the one on [Hadoop](../hadoop/install.md).

## Building Spark with Easybuild

We'll proceed in what should become you  classical approach:

```
$> vagrant ssh    # Or 'vagrant ssh default', if not yet done
$> mu
$> module av      # or 'module available' or 'ma'

# Search for available ReciPY for spark
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



Install it globally (_i.e._ with `eb --installpath=/opt/apps/ [...]` or `global_eb`):

```
$> cd /vagrant/resources/java
$> time global_eb Spark-2.2.0-Hadoop-2.6-Java-1.8.0_152.eb -Dr   # Dry-run
$> time global_eb Spark-2.2.0-Hadoop-2.6-Java-1.8.0_152.eb -r
```

It takes **approximately 3 min** to have it done.

## Loading the module

```
$> module load devel/Spark

The following have been reloaded with a version change:
  1) lang/Java/1.7.0_80 => lang/Java/1.8.0_152
```

Notice the last message (coming from the fact that Hadoop was previsouly loaded).
That's one of the interest of LMod over the regular Environment Modules.
