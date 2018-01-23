The documentation for this project is handled by [Read the Docs](https://readthedocs.org/), a web service dedicated to documentation management for the open source community.

* [Reference documentation](https://docs.readthedocs.org/en/latest/)

By default, the [`Falkor/tutorials-BD-ML`](https://github.com/Falkor/tutorials-BD-ML) repository is bound to the [Big Data Analytics](http://nesusws-tutorials-bd-dl.rtfd.org) project on [Read the Docs](https://readthedocs.org/).

You might wish to generate locally the docs.
To do that, install [`mkdocs`](http://www.mkdocs.org/#installation)  -- see also [this tutorial](https://varrette.gforge.uni.lu/tutorials/mkdocs.html):

```bash
$> brew install python3 && pip3 install mkdocs    # Mac OS X

# Linux
$> pip install --user mkdocs
# Adapt your PATH and PYTHONPATH environment variables
# Add this in your favorite shell config
export PYTHONPATH=$HOME/.local/lib/python2.7/site-packages:$PYTHONPATH
export PATH=$HOME/.local/bin:$PATH

# Windows
$> choco install pip && pip install mkdocs
```
Then:

* Preview your documentation from the project root by running `mkdocs serve` and visit with your favorite browser the URL `http://localhost:8000`
     - Alternatively, you can run `make doc` at the root of the repository.
* build the full documentation locally (in the `site/` directory) by running `mkdocs build`.
