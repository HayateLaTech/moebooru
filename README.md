[![Code Climate](https://codeclimate.com/github/moebooru/moebooru.png)](https://codeclimate.com/github/moebooru/moebooru)

[<img src="https://assets-global.website-files.com/6257adef93867e50d84d30e2/62594fddd654fc29fcc07359_cb48d2a8d4991281d7a6a95d2f58195e.svg" width="130px" />](https://discord.com/invite/monstergirldreams)

Moebooru (MGD_Booru)
========

An image board for MGD User Content.

* [Source Repository](https://github.com/moebooru/moebooru)
* [MGD Patreon](https://patreon.com/monstergirldreams)

Requirements
------------

As this is ongoing project, there will be more changes on requirement as this project goes. Currently this application is developed using:

* Ruby (3.1 or later)
* PostgreSQL (14 or later)
* Bundler gem
* node.js (16.0 or later)
* ImageMagick
* And various other requirement for the gems (check `Gemfile` for the list)

On RHEL, it goes like this (untested):

* ImageMagick
* gcc
* gcc-c++
* git
* jhead
* libxslt-devel
* libyaml-devel
* nodejs
* openssl-devel
* pcre-devel
* postgresql14-devel
* postgresql14-server

Base, EPEL, dnf module, and postgresql official repositories contain all the requirements.

Installation
------------

### Database Setup

After initializing PostgreSQL database, create user for moebooru with `createdb` privilege:

    postgres# create user moebooru_user with password 'the_password' createdb;


### Rails Setup (development)

* Run `bundle install`
* Create `config/database.yml` and `config/local_config.rb`
* Initialize database with `bundle exec rake db:reset`
* Run `bundle exec rake db:migrate`
* Start the server (`bundle exec rails server`)
* Start asset builder server (`npm run build -- --watch`)

Configuration
-------------

See `config/local_config.rb.example`. Additionally, as I move to ENV-based configuration, here's the list of currently supported ENV variables:

- `MB_DATABASE_URL`: sets database connection configuration. Syntax: `postgres://<user>(:<pass>)@<host>(:<port>)/<dbname>`.
- `MB_MEMCACHE_SERVERS`: addresses of memcache servers. Separated by comma.
- `MB_PIWIK_HOST`: sets the host this application will attempt to contact a Piwik installation at. Defaults to false to not use Piwik if unset.
- `MB_PIWIK_ID`: sets the Site ID this application will send analytics data for.
- `MB_THREADS`: sets number of threads this application is running. Currently used to determine number of connection pool for `memcached`. Defaults to 1 if unset.

VSCode + WSL2 Setup (Ubuntu)
-------------

### General Dependencies

    sudo apt-get install build-essential libxml2-dev libxslt1-dev libpq-dev git jhead imagemagick

* [Install NodeJS on wsl](https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-wsl#install-nvm-nodejs-and-npm)

### Postgresql Setup

    sudo apt-get install postgresql-14

Make sure the postgresql server is running. (`/etc/init.d/postgresql status` returns running)

    su - postgres
    psql
    CREATE USER moebooru_user WITH PASSWORD 'password' CREATEDB;

⚠️ The `;` at the end is important!

### Installing Ruby (3.1.2)

[linuxhint.com > 3 Ways to install Ruby on Ubuntu](https://linuxhint.com/ways-install-ruby-ubuntu/)

    sudo apt update
    sudo apt install git curl autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    source ~/.bashrc
    rbenv install ruby 3.1.2
    rbenv global 3.1.2

### Ruby Bundler

    gem install bundler

### Config Files

    cp config/database.yml.example config/database.yml
    cp config/local_config.rb.example config/local_config.rb
    chmod 700 config/database.yml
    chmod 700 config/local_config.rb

| File | Use |
|------|-----|
| database.yml | contains database connection settings (user, pw, tablenames, psql connection) |
| local_config.rb | general application configuration - mainly used to override `init-config.rb` |

⚠️ You need to use the username + password you set in the Postgresql Setup in the `database.yml`.

### MoeBooru Setup (for development)

    bundle install // installs all ruby dependencies
    bundle exec rake db:reset // Drop + Create Tables
    bundle exec rake db:migrate // Applies Migrations to DB
    bundle exec rake assets:precompile // Generates CSS + JS Files

If all that works flawlessly you can run:

    bundle exec rails server // Starts the development Server on Port 3000
    npm run build -- --watch // automatically watches for file-changes and generates CSS + JS

✔️ Navigate to `localhost:3000` and it should display the moebooru website! ^w^

If chu run into problems, just ask me on Discord! 😸