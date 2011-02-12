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
    create_tables
    refresh_if_needed
  end

  def inspect
    "#<PivotalShell::Cache #{@filename}>"
  end

  def refresh
    load_stories(modified_since => self[:updated_at])
  end

  def [](key)
    resultset = db.execute('SELECT value FROM settings WHERE name=?', key.to_s)
    resultset.empty? ? nil : YAML.load(resultset.first.first)
  end

  def []=(key, value)
    db.execute('REPLACE INTO settings (name, value) VALUES (?,?)', key.to_s, YAML.dump(value))
    value
  end

  def users
    @users ||= load_users_from_cache
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
      db.execute('REPLACE INTO USERS (name, role, initials, email) VALUES(?,?,?,?)', membership.name, membership.role, membership.initials, membership.email)
    end
    @users = load_users_from_cache
  end

  def load_users_from_cache
    db.execute('SELECT name, id, role, initials, email FROM users').inject({}) do |hash,row|
      hash[row[0]] = {:id => row[1], :role => row[2], :initials => row[3], :email => row[4]}
      hash
    end
  end

  def user_id_by_name(name)
    user = users[name]
    if user.nil?
      load_users
      user = users[name]
    end
    user && user[:id]
  end

  def save_stories_to_cache(stories)
    query= 'REPLACE INTO STORIES (id, url, name, description, story_type, estimate, labels, current_state, requested_by_id, owned_by_id, created_at, accepted_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)'
    stories.each do |story|
      requested_by_id = user_id_by_name(story.requested_by)
      owned_by_id = user_id_by_name(story.owned_by)
      created_at = story.created_at && story.created_at.strftime("%Y-%m-%d %H:%M:%S")
      accepted_at = story.accepted_at && story.accepted_at.strftime("%Y-%m-%d %H:%M:%S")
      db.execute query, story.id, story.url, story.name, story.description, story.story_type, story.estimate, story.labels, story.current_state, requested_by_id, owned_by_id, created_at, accepted_at
    end
  end

  def create_tables
    db.execute('CREATE TABLE IF NOT EXISTS settings (name VARCHAR NOT NULL, value VARCHAR)')
    db.execute('CREATE UNIQUE INDEX IF NOT EXISTS settings_name ON settings(name)')
    db.execute('CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, role VARCHAR NOT NULL, name VARCHAR NOT NULL, initials VARCHAR NOT NULL, email VARCHAR NOT NULL)')
    db.execute('CREATE UNIQUE INDEX IF NOT EXISTS users_name ON users(name)')
    db.execute(<<SQL
      CREATE TABLE IF NOT EXISTS stories (
        id INT PRIMARY KEY,
        url VARCHAR NOT NULL,
        name VARCHAR NOT NULL,
        description TEXT,
        story_type VARCHAR,
        estimate INT,
        labels VARCHAR,
        current_state VARCHAR,
        requested_by_id INT,
        owned_by_id INT,
        created_at DATETIME,
        accepted_at DATETIME
      )
SQL
    )
  end
end
