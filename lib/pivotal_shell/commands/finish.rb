#<PivotalTracker::Story:0x90b74f4 @jira_url=nil, @requested_by="Pavel Pavlovsky", @name="Add titles for the pages", @attachments=[], @project_id=110960, @jira_id=nil, @id=5952583, @current_state="accepted", @integration_id=nil, @accepted_at=#<DateTime: 212157861559/86400,1/12,2299161>, @labels="ui", @url="http://www.pivotaltracker.com/story/show/5952583", @estimate=nil, @description="so they are identified correctly by user.\nto clarify", @other_id=nil, @created_at=#<DateTime: 5303878313/2160,1/8,2299161>, @owned_by="Leonid Shevtsov", @story_type="chore">
require 'optparse'

module PivotalShell::Commands
  class PivotalShell::Commands::Finish < PivotalShell::Command
    def initialize(options)
      opts = OptionParser.new do |opts|
        opts.banner = "Finish a Pivotal story. The story must be started.\nUsage: pivotal finish STORY_ID [options]\n\n"
        
        opts.on_tail('--help', 'Show this help') do
          puts opts
          exit
        end
      end
      opts.parse!(options)
      if options.empty? || options.length>1
        puts opts
        exit
      else
        @story_id = options.first
      end
    end

    def execute
      @story = PivotalShell::Configuration.project.stories.find(@story_id)
      if @story.nil?
        puts 'Story not found'
      elsif @story.current_state!='started'
        puts 'Story is not in a started state: '+@story.name
      else
        @story.update(:current_state => 'started')
      end
    end
  end
end
