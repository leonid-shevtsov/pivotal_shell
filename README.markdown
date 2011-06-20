# pivotal_shell

A command-line client for [Pivotal Tracker](http://www.pivotaltracker.com)

## Installation

    gem install pivotal_shell

## Configuration

First, you need to [create an API token for your profile](https://www.pivotaltracker.com/profile) (scroll to the bottom) and put it into `~/.pivotalrc`:

    api_token: abcdef0123456789

The token is the same for all of your Pivotal Tracker projects.

Second, you need to create a `.pivotalrc` in your project root and set up projectwide settings:

    # For the https://www.pivotaltracker.com/projects/123456 project, the id would be...
    project_id: 123456

    # these are your initials used in the project
    me: LS

    # add this if your project requires SSL (otherwise you may receive 400 Bad Request)
    use_ssl: true

Both `.pivotalrc` files are regular YAML files.

## Usage

    pivotal

## Example

List all your unfinished stories

    pivotal stories

List all your stories, regardless of status

    pivotal stories --all --mine

List all finished stories for everyone
  
    pivotal stories --all --finished

List all unassigned bugs

    pivotal stories --unowned --bugs

Show info on a story
    
    pivotal story 123456

Start story

    pivotal start 123456

Finish story

    pivotal finish 123456

## Caching

`pivotal-shell` caches story and user information into a local database. This can greatly speed up execution since Pivotal Tracker can be *slooow* sometimes.
The database is synchronised with the actual project data each 15 minutes (that is, if you call a `pivotal` command and the database is older that 15 minutes, it's updated).
To change this interval, use the `refresh_interval` parameter in the global or project `.pivotalrc`; the value is in minutes; set it to `-1` to completely disable updating, which can be
useful if you're going to do it by `cron`.

There are two commands related to caching:

    pivotal update # update stories from the server

    pivotal reload # completely reinitialize the database; use this in case of bugs

You can add this to your crontab to enable autoupdate:

    0,15,30,45 * * * * cd /your/project/path && pivotal update

## TODO

* Commit (with git, all comments after the story id go to git, story id gets appended to comments)

    pivotal commit 123456 "some more comments"

* Refactor caching code
