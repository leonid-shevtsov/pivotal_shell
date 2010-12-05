# pivotal_shell

A command-line wrapper for [Pivotal Tracker](http://www.pivotaltracker.com)

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

## TODO

Commit (with git, all comments after the story id go to git, story id gets appended to comments)

    pivotal commit 123456 "some more comments"
