
# Machine/Deep Learning with Tensorfow

_Reference_:

* [Deep Learning with Apache Spark and TensorFlow](https://databricks.com/blog/2016/01/25/deep-learning-with-apache-spark-and-tensorflow.html)
* [Tensorflow tutorial on MNIST](https://www.tensorflow.org/versions/master/get_started/mnist/beginners)
    - MNIST dataset: see [Yann LeCun's website](http://yann.lecun.com/exdb/mnist/)


THis hands-on is **not** about learning ML/DL.
JUst as a short reminder, here are the main steps in ML:

* __Step 0 - 1__: Asking the right questions
* __Step 2 - 4__: Getting the right data
* __Step 5 - 7__: Finding patterns in the data
* __Step 8 - 9__: Checking the patterns work on new data
* __Step 10__:    Building a production-ready system
* __Step 11__:    Making sure that launching is a good idea
* __Step 12__:    Keeping a production ML system reliable over time

Math is finally just serving for

* Finding pattern (within old data)
* Assessing model performance (over the new data)

Finally, the **Biggest pitfalls** you should try to avoid are:

* _overfitting_: harder to detect but the most nightmare for ML (corresponds to having extracted a model out of noise)
* _underfitting_


## Step 1: Python Setup

For this tutorial, we will work natively on your laptop.

Here we are going to setup the environment in an isolated python environment using [pyenv](https://github.com/pyenv/pyenv) and [virtualenv](https://virtualenv.pypa.io/en/stable/)


Follow the instructions provided on  [this blog post](https://varrette.gforge.uni.lu/blog/2017/11/22/using-pyenv-virtualenv-direnv/).
You will find the relevant files for `direnv` (if you wish to use it) at the root of this repository:

* `config/direnv/direnvrc`: Global configuration for direnv to make it compliant with [pyenv](https://direnv.net/) you will need to place in `~/.config/direnv`
* `config/direnv/envrc`: a template for a `.envrc` file you can place within your directory.

Once you have completed the installation of [pyenv](https://github.com/pyenv/pyenv) and [virtualenv](https://virtualenv.pypa.io/en/stable/):

```
# Setup a root project directory
$> mkdir -p ~/tutorials/NESUS-WS/BD-ML
$> cd ~/tutorials/NESUS-WS/BD-ML
$> ln -s ~/git/github.com/Falkor/tutorials-BD-ML ref.d

# Install the versions of Python
$> pyenv versions
* system
$> pyenv install 2.7.14
$> pyenv install 3.2       # Eventually if you wish to test python 3

# Prepare the configuration
$> echo '2.7.14'  > .python-version
$> echo 'nesusWS' > .python-virtualenv
$> ln -s ref.d/config/direnv/envrc .envrc
$> ln -s .envrc setup.sh

$> source setup.sh   # Actually activate the python setup
$> direnv allow
$> pyenv virtualenvs
```

## Step 2. Install Tensorflow

See also [installation notes](https://www.tensorflow.org/install/)

Assuming you work within a pyenv virtualenv environment:

```
$> pyenv virtualenvs
  2.7.14/envs/nesusWS-2.7.14 (created from /usr/local/opt/pyenv/versions/2.7.14)
* nesusWS-2.7.14 (created from /usr/local/opt/pyenv/versions/2.7.14)
$> python -V
Python 2.7.14
$> pip install --upgrade tensorflow
```

## Step3. Install Jupyter

See <https://jupyter.org/install.html>

```bash
$> brew install jupyter
[...]
# You can now run 'ipython' over Python 2:
$> /usr/local/opt/ipython@5/bin/ipython
/usr/local/Cellar/ipython@5/5.5.0_1/libexec/lib/python2.7/site-packages/IPython/core/interactiveshell.py:726: UserWarning: Attempting to work in a virtualenv. If you encounter problems, please install IPython inside the virtualenv.
  warn("Attempting to work in a virtualenv. If you encounter problems, please "
Python 2.7.14 (default, Sep 25 2017, 09:53:22)
Type "copyright", "credits" or "license" for more information.

IPython 5.5.0 -- An enhanced Interactive Python.
```

Now if you want to use the `nesusWS` virtualenv within a new Jupyter notebook, you'll need to follow the instructions provided on the following page: [Using a virtualenv in an IPython notebook](https://help.pythonanywhere.com/pages/IPythonNotebookVirtualenvs/)

```
$> pip install ipykernel

# Now run the kernel "self-install" script to create a new kernel nesusWS
$> python -m ipykernel install --user --name=nesusWS
```

You can now start a notebook

```
$> cd ref.d/docs/hands-on/tensorflow/
$> jupyter notebook

# See 'Kernel -> Change kernel' and eventually switch to 'nesusWS' upon new page
```

You are ready to open the provided tutorials -- [See `mnist.md`](mnist.md)
