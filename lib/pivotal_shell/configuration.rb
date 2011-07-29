require 'yaml'
require 'pivotal_tracker'

module PivotalShell::Configuration
  DEFAULTS = {
    'refresh_interval' => 15
  }

  def self.load
    @global_config = YAML.load_file(global_config_path)
    @project_config = YAML.load_file(File.join(project_config_path,'.pivotalrc'))
    PivotalTracker::Client.token = @global_config['api_token']
    PivotalTracker::Client.use_ssl = @project_config['use_ssl']
  end

  def self.project
    @project ||= PivotalTracker::Project.find(@project_config['project_id'])
  end

  def self.cache
    @cache ||= PivotalShell::Cache.new(File.join(project_config_path,'.pivotal_cache'))
  end

  def self.me
    @me ||= @project_config['me']
  end

  def self.refresh_interval
    @refresh_interval ||= @project_config['refresh_interval'] || @global_config['refresh_interval'] || DEFAULTS['refresh_interval']
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
      'started' => $terminal.color('S', :white),
      'finished' => $terminal.color('F', :yellow), 
      'delivered' => $terminal.color('D', :yellow), 
      'accepted' => $terminal.color('A', :green), 
      'rejected' => $terminal.color('R', :red)
    }[status]
  end

  def self.estimate_icon(estimate)
    (estimate.nil? ? ' ' : ({-1 => '?', 0 => '0', 1=>'1', 2=>'2', 3 => '3'}[estimate] || estimate.to_s)).rjust 2
  end

  def self.type_icon(type)
    {
      'feature' => $terminal.color('F', :yellow), 
      'chore' => $terminal.color('C', :white), 
      'bug' => $terminal.color('B', :red)
    }[type]
  end

  def self.icon(type, status, estimate)
    type_icon(type).to_s + ' ' + estimate_icon(estimate).to_s + ' ' + status_icon(status).to_s
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
      File.join(dirs)
    end
  end
end
