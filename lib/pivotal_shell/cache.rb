#<PivotalTracker::Story:0x90b74f4 
#@jira_url=nil, 
#@requested_by="Pavel Pavlovsky", 
#@name="Add titles for the pages", 
#@attachments=[], 
#@project_id=110960, 
#@jira_id=nil, 
#@id=5952583, 
#@current_state="accepted", 
#@integration_id=nil, 
#@accepted_at=#<DateTime: 212157861559/86400,1/12,2299161>, 
#@labels="ui", 
#@url="http://www.pivotaltracker.com/story/show/5952583", 
#@estimate=nil, 
#@description="so they are identified correctly by user.\nto clarify", 
#@other_id=nil, 
#@created_at=#<DateTime: 5303878313/2160,1/8,2299161>, 
#@owned_by="Leonid Shevtsov", 
#@story_type="chore">
require 'sqlite3'
require 'pivotal_shell/configuration'

class PivotalShell::Cache
  STORY_ATTRIBUTES=%w(requested_by_id name id current_state accepted_at labels url estimate description created_at owned_by_id story_type)
  
  attr_reader :db

  def initialize(filename)
    @filename = filename
    @db = SQLite3::Database.new(@filename)
    @db.results_as_hash = true
    create_tables
    refresh_if_needed
  end

  def inspect
    "#<PivotalShell::Cache #{@filename}>"
  end

  def refresh
    load_stories(:modified_since => self[:last_updated_at])
  end

  def reload
    db.execute('DELETE FROM users')
    db.execute('DELETE FROM stories')
    @users = nil
    load_stories
  end

  def [](key)
    resultset = db.execute('SELECT value FROM settings WHERE name=?', key.to_s)
    resultset.empty? ? nil : YAML.load(resultset.first['value'])
  end

  def []=(key, value)
    db.execute('REPLACE INTO settings (name, value) VALUES (?,?)', key.to_s, YAML.dump(value))
    value
  end

  def users
    @users ||= load_users_from_cache
  end

  def user(id)
    db.execute('SELECT * FROM users WHERE id=?', id).first
  end

  def story(id)
    story = db.execute('SELECT * FROM stories WHERE id=?', id).first
    unless story.nil?
      story['owned_by'] = user(story['owned_by_id'])
      story['requested_by'] = user(story['requested_by_id'])
      puts story.inspect
    end
    story
  end

protected

  def refresh_if_needed
    updated_at = self[:last_updated_at]
    if updated_at.nil?
      puts 'Retrieving all stories from Pivotal Tracker. This could take a while...'
      load_stories
    else
      refresh if self[:last_updated_at]+PivotalShell::Configuration.refresh_interval*60 < Time.now
    end
  end

  def load_stories(options={})
    # Pivotal Tracker API limits one stories call to 3000 results. Thus we need to paginate.
    all_stories = []
    limit = 3000
    offset = 0
    begin
      new_stories = PivotalShell::Configuration.project.stories.all(options.merge(:limit => limit, :offset => offset))
      all_stories += new_stories unless new_stories.empty?
      offset+=limit
    end until new_stories.empty?
    save_stories_to_cache(all_stories)
    self[:last_updated_at] = Time.now
  end

  def load_users
    PivotalShell::Configuration.project.memberships.all.each do |membership|
      if row = db.execute('SELECT id FROM users WHERE name=?', membership.name).first
        db.execute('UPDATE USERS SET role=?, initials=?, email=? WHERE id=?', membership.role, membership.initials, membership.email, row['id'])
      else
        db.execute('INSERT INTO USERS (name, role, initials, email) VALUES(?,?,?,?)', membership.name, membership.role, membership.initials, membership.email)
      end
    end
    @users = load_users_from_cache
  end

  def load_users_from_cache
    db.execute('SELECT id,name,role,initials,email FROM users').inject({}) do |hash,row|
      hash[row['name'].to_s] = row
      hash
    end
  end

  def user_id_by_name(name)
    name=name.to_s
    return nil if name==''
    user = users[name]
    if user.nil?
      load_users
      user = users[name]
      if user.nil?
        db.execute('INSERT INTO USERS (name, role, initials, email) VALUES(?,"","","")', name)
        load_users_from_cache
        user=users[name]
      end
    end
    user && user['id']
  end

  def save_stories_to_cache(stories)
    insert_query = 'INSERT INTO stories (url, name, description, story_type, estimate, labels, current_state, requested_by_id, owned_by_id, created_at, accepted_at, id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)'
    update_query = 'UPDATE stories SET url=?, name=?, description=?, story_type=?, estimate=?, labels=?, current_state=?, requested_by_id=?, owned_by_id=?, created_at=?, accepted_at=? WHERE id=?'
    stories.each do |story|
      requested_by_id = user_id_by_name(story.requested_by)
      owned_by_id = user_id_by_name(story.owned_by)
      created_at = story.created_at && story.created_at.strftime("%Y-%m-%d %H:%M:%S")
      accepted_at = story.accepted_at && story.accepted_at.strftime("%Y-%m-%d %H:%M:%S")
      query = db.execute('SELECT id FROM stories WHERE id=?', story.id).first ? update_query : insert_query
      db.execute query, story.url, story.name, story.description, story.story_type, story.estimate, story.labels, story.current_state, requested_by_id, owned_by_id, created_at, accepted_at, story.id
    end
  end

  def create_tables
    db.execute('CREATE TABLE IF NOT EXISTS settings (name VARCHAR NOT NULL, value VARCHAR)')
    db.execute('CREATE UNIQUE INDEX IF NOT EXISTS settings_name ON settings(name)')
    db.execute('CREATE TABLE IF NOT EXISTS users (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, role VARCHAR NOT NULL, name VARCHAR NOT NULL, initials VARCHAR NOT NULL, email VARCHAR NOT NULL)')
    db.execute('CREATE UNIQUE INDEX IF NOT EXISTS users_name ON users(name)')
    db.execute(<<SQL
      CREATE TABLE IF NOT EXISTS stories (
        id INTEGER NOT NULL PRIMARY KEY,
        url VARCHAR NOT NULL,
        name VARCHAR NOT NULL,
        description TEXT,
        story_type VARCHAR,
        estimate INTEGER,
        labels VARCHAR,
        current_state VARCHAR,
        requested_by_id INTEGER,
        owned_by_id INTEGER,
        created_at DATETIME,
        accepted_at DATETIME
      )
SQL
    )
  end
end
