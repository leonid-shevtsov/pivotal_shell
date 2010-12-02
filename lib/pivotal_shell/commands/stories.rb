#<PivotalTracker::Story:0x90b74f4 @jira_url=nil, @requested_by="Pavel Pavlovsky", @name="Add titles for the pages", @attachments=[], @project_id=110960, @jira_id=nil, @id=5952583, @current_state="accepted", @integration_id=nil, @accepted_at=#<DateTime: 212157861559/86400,1/12,2299161>, @labels="ui", @url="http://www.pivotaltracker.com/story/show/5952583", @estimate=nil, @description="so they are identified correctly by user.\nto clarify", @other_id=nil, @created_at=#<DateTime: 5303878313/2160,1/8,2299161>, @owned_by="Leonid Shevtsov", @story_type="chore">

module PivotalShell::Commands
  class PivotalShell::Commands::Stories < PivotalShell::Command
    def initialize(options)
      opts = OptionParser.new do |opts|
        opts.banner = "List Pivotal stories\nUsage: pivotal stories [options]\n\nThe default is to show all unfinished stories assigned to yourself\n\n"
        
        opts.on_tail('--help', 'Show this help') do
          puts opts
          exit
        end
      end
      opts.parse!
    end

    def execute
      stories = PivotalShell::Configuration.project.stories.all(:owner => PivotalShell::Configuration.me, :state => %w(unestimated unstarted started))

      puts stories.map{|s| "#{("[#{s.id}]").rjust 12} #{PivotalShell::Configuration.icon(s.current_state,s.estimate)} #{s.name}"}.join("\n")
    end
  end
end
