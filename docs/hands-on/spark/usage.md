
**IMPORTANT**: you should have completed the [Hands-on covering the instalaytion of Spark](install.md) to proceed to the below instructions.

In this part, we will review the basic usage of Spark in two cases:

1. a single conffiguration where the classical interactive wrappers (`pyspark`, `scala` and `R` wrappers) will be reviewed.
1. a [Standalone](https://spark.apache.org/docs/latest/spark-standalone.html) cluster configuration - a simple cluster manager included with Spark that makes it easy to set up a cluster), where we will run the Pi estimation.

## Step 1. Interactive usage

### 1.a. Pyspark

PySpark is the Spark Python API and exposes Spark Contexts to the Python programming environment.

```bash
$> pyspark
Python 2.7.5 (default, Aug  4 2017, 00:39:18)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-16)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
18/01/22 23:48:50 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
18/01/22 23:48:51 WARN Utils: Your hostname, vm.vagrant.dev resolves to a loopback address: 127.0.1.1; using 10.0.2.15 instead (on interface eth0)
18/01/22 23:48:51 WARN Utils: Set SPARK_LOCAL_IP if you need to bind to another address
18/01/22 23:49:00 WARN ObjectStore: Version information not found in metastore. hive.metastore.schema.verification is not enabled so recording the schema version 1.2.0
18/01/22 23:49:01 WARN ObjectStore: Failed to get database default, returning NoSuchObjectException
18/01/22 23:49:01 WARN ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 2.2.0
      /_/

Using Python version 2.7.5 (default, Aug  4 2017 00:39:18)
SparkSession available as 'spark'.
>>>
```

See [this tutorial](https://www.dezyre.com/apache-spark-tutorial/pyspark-tutorial) for playing with pyspark.

### 1.b. Scala Spark Shell

Spark includes a modified version of the Scala shell that can be used interactively.
Instead of running `pyspark` above, run the `spark-shell` command:

```bash
$> spark-shell
```

After some initialization output, a scala shell prompt with the Spark context will be available:

```bash
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
18/01/22 23:51:32 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
18/01/22 23:51:32 WARN Utils: Your hostname, vm.vagrant.dev resolves to a loopback address: 127.0.1.1; using 10.0.2.15 instead (on interface eth0)
18/01/22 23:51:32 WARN Utils: Set SPARK_LOCAL_IP if you need to bind to another address
18/01/22 23:51:38 WARN General: Plugin (Bundle) "org.datanucleus.store.rdbms" is already registered. Ensure you dont have multiple JAR versions of the same plugin in the classpath. The URL "file:/opt/apps/software/devel/Spark/2.2.0-Hadoop-2.6-Java-1.8.0_152/jars/datanucleus-rdbms-3.2.9.jar" is already registered, and you are trying to register an identical plugin located at URL "file:/vagrant/easybuild/centos7/software/devel/Spark/2.2.0-Hadoop-2.6-Java-1.8.0_152/jars/datanucleus-rdbms-3.2.9.jar."
18/01/22 23:51:38 WARN General: Plugin (Bundle) "org.datanucleus.api.jdo" is already registered. Ensure you dont have multiple JAR versions of the same plugin in the classpath. The URL "file:/vagrant/easybuild/centos7/software/devel/Spark/2.2.0-Hadoop-2.6-Java-1.8.0_152/jars/datanucleus-api-jdo-3.2.6.jar" is already registered, and you are trying to register an identical plugin located at URL "file:/opt/apps/software/devel/Spark/2.2.0-Hadoop-2.6-Java-1.8.0_152/jars/datanucleus-api-jdo-3.2.6.jar."
18/01/22 23:51:38 WARN General: Plugin (Bundle) "org.datanucleus" is already registered. Ensure you dont have multiple JAR versions of the same plugin in the classpath. The URL "file:/vagrant/easybuild/centos7/software/devel/Spark/2.2.0-Hadoop-2.6-Java-1.8.0_152/jars/datanucleus-core-3.2.10.jar" is already registered, and you are trying to register an identical plugin located at URL "file:/opt/apps/software/devel/Spark/2.2.0-Hadoop-2.6-Java-1.8.0_152/jars/datanucleus-core-3.2.10.jar."
18/01/22 23:51:45 WARN ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
Spark context Web UI available at http://10.0.2.15:4040
Spark context available as 'sc' (master = local[*], app id = local-1516665095099).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.2.0
      /_/

Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_152)
Type in expressions to have them evaluated.
Type :help for more information.

scala>
```


### 1.c.  R Spark Shell

The Spark R API is still experimental. Only a subset of the R API is available -- See the [SparkR Documentation](https://spark.apache.org/docs/latest/sparkr.html).
Since this tutorial does not cover R, we are not going to use it.


## Step 2. Running Spark standalone cluster

* [Reference Documentation](https://spark.apache.org/docs/latest/cluster-overview.html)


Spark applications run as independent sets of processes on a cluster, coordinated by the SparkContext object in your main program (called the driver program).

Specifically, to run on a cluster, the SparkContext can connect to several types of cluster managers (either Spark’s own standalone cluster manager, Mesos or YARN), which allocate resources across applications. Once connected, Spark acquires executors on nodes in the cluster, which are processes that run computations and store data for your application. Next, it sends your application code (defined by JAR or Python files passed to SparkContext) to the executors. Finally, SparkContext sends tasks to the executors to run.

![](https://spark.apache.org/docs/latest/img/cluster-overview.png)

There are several useful things to note about this architecture:

1. Each application gets its own executor processes, which stay up for the duration of the whole application and run tasks in multiple threads. This has the benefit of isolating applications from each other, on both the scheduling side (each driver schedules its own tasks) and executor side (tasks from different applications run in different JVMs). However, it also means that data cannot be shared across different Spark applications (instances of SparkContext) without writing it to an external storage system.
2. Spark is agnostic to the underlying cluster manager. As long as it can acquire executor processes, and these communicate with each other, it is relatively easy to run it even on a cluster manager that also supports other applications (e.g. Mesos/YARN).
3. The driver program must listen for and accept incoming connections from its executors throughout its lifetime (e.g., see spark.driver.port in the network config section). As such, the driver program must be network addressable from the worker nodes.
4. Because the driver schedules tasks on the cluster, it should be run close to the worker nodes, preferably on the same local area network. If you'd like to send requests to the cluster remotely, it's better to open an RPC to the driver and have it submit operations from nearby than to run a driver far away from the worker nodes.

**Cluster Manager**

Spark currently supports three cluster managers:

* [Standalone](https://spark.apache.org/docs/latest/spark-standalone.html) – a simple cluster manager included with Spark that makes it easy to set up a cluster.
* [Apache Mesos](https://spark.apache.org/docs/latest/running-on-mesos.html) – a general cluster manager that can also run Hadoop MapReduce and service applications.
* [Hadoop YARN](https://spark.apache.org/docs/latest/running-on-mesos.html) – the resource manager in Hadoop 2.

In this part, we will deploy a **standalone cluster**.

You will need to prepare a script that will:

1. create a master and the workers
2. submit a spark application to the cluster using the `spark-submit` script
3. Let the application run and collect the result
4. stop the cluster at the end.

To facilitate these steps, Spark comes with a couple of scripts you can use to launch or stop your cluster, based on Hadoop's deploy scripts, and available in `$EBROOTSPARK/sbin`:

| Script                 | Description                                                                             |
|------------------------|------------------------------------------------------------------------------|
| `sbin/start-master.sh` | Starts a master instance on the machine the script is executed on.           |
| `sbin/start-slaves.sh` | Starts a slave instance on each machine specified in the conf/slaves file.   |
| `sbin/start-slave.sh`  | Starts a slave instance on the machine the script is executed on.            |
| `sbin/start-all.sh`    | Starts both a master and a number of slaves as described above.              |
| `sbin/stop-master.sh`  | Stops the master that was started via the bin/start-master.sh script.        |
| `sbin/stop-slaves.sh`  | Stops all slave instances on the machines specified in the conf/slaves file. |
| `sbin/stop-all.sh`     | Stops both the master and the slaves as described above.                     |


_Hint_: Don't forget to export SPARK_HOME to point to the Easybuild install

```bash
export SPARK_HOME=$EBROOTSPARK
```

Don't forget to export SPARK_HOME to point to the Easybuild install

```bash
# sbin/start-master.sh - Starts a master instance on the machine the script is executed on.
$SPARK_HOME/sbin/start-all.sh

export MASTER=spark://$HOSTNAME:7077

echo
echo "========= Spark Master ========"
echo $MASTER
echo "==============================="
echo
```

Now you can submit an example python Pi estimation script to the Spark cluster with 100 partitions

_Note_: partitions in this context refers of course to Spark's Resilient Distributed Dataset (RDD) and how the dataset is distributed across the nodes in the Spark cluster.

```bash
spark-submit --master $MASTER  $SPARK_HOME/examples/src/main/python/pi.py 100
```

Finally, at the end, clean your environment and

```bash
# sbin/stop-master.sh - Stops the master that was started via the bin/start-master.sh script.
$SPARK_HOME/sbin/stop-all.sh
```

When the job completes, you can find the Pi estimation result

```
[...]
Pi is roughly 3.147861
```
