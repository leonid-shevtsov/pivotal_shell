require 'yaml'
require 'pivotal_tracker'

module PivotalShell::Configuration
  def self.load
    @global_config = YAML.load_file(global_config_path)
    @project_config = YAML.load_file(project_config_path)
    PivotalTracker::Client.token = @global_config['api_token']
  end

  def self.project
    @project ||= PivotalTracker::Project.find(@project_config['project_id'])
  end

  def self.me
    @me ||= @project_config['me']
  end

  def self.global_config_path
    @global_config_path ||= File.expand_path('~/.pivotalrc')
  end

  def self.project_config_path
    @project_config_path ||= find_project_config
  end

  def self.status_icon(status)
    {
      'unscheduled' => ' ', 
      'unstarted' => '.', 
      'started' => 'S',
      'finished' => 'F', 
      'delivered' => 'D', 
      'accepted' => 'A', 
      'rejected' => 'R'
    }[status]
  end

  def self.estimate_icon(estimate)
    estimate.nil? ? '*' : {-1 => '?', 1=>'1', 2=>'2', 3 => '3'}[estimate]
  end

  def self.icon(status,estimate)
    estimate_icon(estimate)+status_icon(status)
  end

private

  def self.find_project_config
    dirs = File.split(Dir.pwd)
    until dirs.empty? || File.exists?(File.join(dirs, '.pivotalrc'))
      dirs.pop
    end
    if dirs.empty? || File.join(dirs, '.pivotalrc')==global_config_path
      raise PivotalShell::Exception.new('No project .pivotalrc found')
    else
      File.join(dirs, '.pivotalrc')
    end
  end
end
