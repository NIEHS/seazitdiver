## Quickstart development environment

> **Note:** For up-to-date installation instructions, see the [top-level README](../../README.md). This page contains legacy notes and detailed reference material that may reference deprecated files (e.g., `docker-compose-dev.yml`).

Installing the SEAZIT application requires installation both a webserver and a database. The following pre-requisites are required:

- Anaconda or Miniconda
- Docker and Docker compose

### The application environment (python + javascript)

Installation instructions described below. Note that the instructions assume the NTP SEAZIT will be installed to ``~/dev/seazitdiver`` and a conda environment will be created which is named ``SEAZIT``; both of these settings can be changed but instructions will need to be updated:

```bash
cd ~/dev
 
git clone https://github.com/NIEHS/seazitdiver.git 

cd ./SEAZIT
conda env create -f conda.yml

# install python requirements in new conda environment
conda activate SEAZIT
brew install freetype
pip install -r requirements/dev.txt
conda install pygraphviz

# copy default local settings (and modify as needed)
cp ./project/main/settings/local.example.py ./project/main/settings/local.py
# install javascript libraries
cd ./project
yarn install
```
Installation notes:


### The database environment (postgreSQL) 

There are two options for SEAZIT to access database. If you have vpn connect you can chose either option 1 or 2. If you cannot access vpn you need install database on your local box which is option 1

**Option 1.** Install local docker db
Create a docker environment file at the root `sandbox` directory named `.env`. Add the following variables:

```
POSTGRES_USER=sandbox
POSTGRES_PASSWORD=my_dev_password
DB_USER=sandbox
```

Build and run the docker container:

```bash
docker-compose -f ./docker-compose-dev.yml build postgres
docker-compose -f ./docker-compose-dev.yml up -d postgres
```

To confirm the database is working, connect via a local psql client:

```bash
psql -U sandbox -p 5433 -h localhost
```

You can save your password in the file `~/.pgpass` instead of having to re-enter it ([docs](https://www.postgresql.org/docs/9.6/static/libpq-pgpass.html)) each time you try to connect to the database:

    localhost:5433:sandbox:sandbox:my_dev_password

Ensure that your settings in `./project/main/settings/local.py` allow you test connect to the database. Now, sync database state with python state:

**option 2.** Database connect to NTP dev server (need vpn connection)

```bash
--Detail coming soon
--see NTP database admin
```

```bash
source activate SEAZIT
cd ~/dev/sandbox/project
python manage.py migrate  # sync application <-> database
python manage.py createsuperuser  # for admin login
```

### Running all the things

To run the development environment, you'll need to run an instance of the django web application, and an instance of the javascript webpack builder. You'll need to run them in two different terminal windows.

```bash
# python [in the first terminal]
conda activate SEAZIT
cd ~/dev/SEAZIT/project
python manage.py runserver 8000

#Running with just:
 
#only makes the system available via localhost
#if it is a server Use :
#python manage.py runserver 0.0.0.0:8000 to make it listen on all interfaces

# javascript [in a second terminal]
conda activate SEAZIT
cd ~/dev/SEAZIT/project
npm start
```
optional :

```bash
load SEAZIT data:
cp SEAZIT.sql to your server
psql -h localhost -p 5433 -d sandbox -U sandbox -f SEAZIT.sql
```

Navigate to [http://127.0.0.1:8000/](http://127.0.0.1:8000/), and you should be able to see the NTP SEAZIT homepage!

For convenience, a Makefile is available which starts a developer environment in one shell using [tmux](https://tmux.github.io/). The Makefile is designed such that if a local version of the tmux configuration is present, it is called instead, which allows more user-specific customization of the application.

```bash
cd ~/dev/sandbox
make dev

# to customize your tmux environment; edit dev.local.sh
cp ./bin/dev.sh ./bin/dev.local.sh

# remove lines 5-9 to prevent recursive seg fault in dev.local.sh
vim ./bin/dev.local.sh
```

**Note: ** Note that all conda environments must be deactivated before trying to run the tmux script, otherwise changing conda environments will fail ([details](https://github.com/conda/conda/issues/6796)).

### Simplifying commands by modifying environment variables

You can modify conda environments to set environment variables or other settings when activating the environment. Below, we create an alias to for running docker-compose with our development settings; you may find benefit in adding other settings to reduce keystrokes.

For more details, read the [docs](https://conda.io/docs/user-guide/tasks/manage-environments.html#saving-environment-variables). The example below includes all required steps:

```bash
conda activate SEAZIT
cd $CONDA_PREFIX
mkdir -p ./etc/conda/activate.d
mkdir -p ./etc/conda/deactivate.d
touch ./etc/conda/activate.d/env_vars.sh
touch ./etc/conda/deactivate.d/env_vars.sh
```

In ``./etc/conda/activate.d/env_vars.sh``:

```
alias dc="docker-compose -f ./docker-compose-dev.yml"
cd ~/dev/sandbox
```

In ``./etc/conda/deactivate.d/env_vars.sh``:

```
unalias dc
cd ~
```

## Documentation environment

Docs are built using [mkdocs](http://www.mkdocs.org/). The project Makefile includes a directive to create the documentation build server:

```bash
make servedocs
```


Diagrams are generated using [mermaid](https://github.com/mermaidjs/mermaid.cli); install using yarn. The [online editor](https://mermaidjs.github.io/mermaid-live-editor/) is helpful for rapidly iterating; to build from files:

```bash
cd docs

mmdc -t neutral -C ./diagrams/mmd.css \
    -i ./diagrams/containers.mmd \
    -o ./docs/static/containers.png
```

## Testing environment

Testing the base django-application is done using the ``make test`` command; tests are implemented using [pytest](https://pytest.org/); refer to the library details for more advanced testing questions.

## Additional application-specific install requirements

The installation above is the minimal installation to get a working environment; to test some features which may application-specific, see the additional notes by application:

- [shiny applications](/apps/shiny/#developer-instructions)

## FAQ

### Generate ER models for django applications

Entity-relationship models can be automatically created using django and the django extensions module. To create ER diagrams:

## Error fixing:
update base.py: 

cd /opt/anaconda3/envs/seazit/lib/python3.8/site-packages/selectable/base.py
(use nano or something edit base.py file)

from django.core.urlresolvers import reverse, NoReverseMatch

from django.urls import reverse, NoReverseMatch


1. Solution option 1.


2. pip unisntall markdown

*******
##matplotlib RuntimeError: 
"Python is not installed as a framework.""

Add a line:
  backend: TkAgg

in file: ~/.matplotlib/matplotlibrc

---------------
remove the conda env
conda deactivate
conda remove --name seazit --all

 yarn -v
4.3.1
(seazit) ALMBP02246215:seazitdiver noltesz$ npm -v
10.8.2
(seazit) ALMBP02246215:seazitdiver noltesz$ node -v
v22.5.1
(seazit) ALMBP02246215:seazitdiver noltesz$

update local npm version
npm update -g npm


