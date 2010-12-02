
Examples

    #~/.pivotalrc
    api_key: abcdef0123456789

    #project/.pivotalrc
    project_id: 123456

List all your unfinished stories

    pivotal stories

List all your stories

    pivotal stories --status any

List all finished stories for everyone
  
    pivotal stories --status finished --for everyone

Start story

    pivotal start 123456

Finish story

    pivotal finish 123456

Commit (with git, all comments after the story id go to git, story id gets appended to comments)

    pivotal commit 123456 "some more comments"
