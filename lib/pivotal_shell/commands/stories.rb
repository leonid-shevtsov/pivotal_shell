#<PivotalTracker::Story:0x90b74f4 @jira_url=nil, @requested_by="Pavel Pavlovsky", @name="Add titles for the pages", @attachments=[], @project_id=110960, @jira_id=nil, @id=5952583, @current_state="accepted", @integration_id=nil, @accepted_at=#<DateTime: 212157861559/86400,1/12,2299161>, @labels="ui", @url="http://www.pivotaltracker.com/story/show/5952583", @estimate=nil, @description="so they are identified correctly by user.\nto clarify", @other_id=nil, @created_at=#<DateTime: 5303878313/2160,1/8,2299161>, @owned_by="Leonid Shevtsov", @story_type="chore">

module PivotalShell::Commands
  class PivotalShell::Commands::Stories < PivotalShell::Command
    def initialize(options)
      @options = {:params => {}}


      opts = OptionParser.new do |opts|
        opts.banner = "List Pivotal stories\nUsage: pivotal stories [options]\n\nThe default is to show all unfinished stories assigned to yourself\n\nDisplay format:\n  [id]\n  type: Feature/Bug/Chore\n  estimate: * (irrelevant)/0/1/2/3\n  state: . (unscheduled)/Unstarted/Started/Finished/Delivered/Accepted/Rejected\n  title\n\nOptions:"
        
        
        opts.on('--all', 'Show all tasks (reset default filter on state and owner)') do
          @options[:all] = true
        end

        PivotalShell::Cache::Story::STATUSES.each do |status|
          opts.on("--#{status}", "Show #{status} stories") do
            @options[:params][:state] ||= []
            @options[:params][:state] << status
          end
        end
        
        PivotalShell::Cache::Story::TYPES.each do |type|
          opts.on("--#{type}s", "Show #{type}") do
            @options[:params][:type] ||= []
            @options[:params][:type] << type
          end
        end

        opts.on('--for [USER]', 'Show tasks assigned to USER; accepts comma-separated list') do |user|
          @options[:params][:owner] = user
        end
        
        opts.on('--unowned', 'Show tasks not assigned to anyone') do
          @options[:params][:unowned] = true
        end
        
        opts.on('--anyone', 'Show tasks assigned to anyone') do
          @options[:anyone] = true
        end

        opts.on('--mine', 'Show your tasks') do
          @options[:params][:owner] = PivotalShell::Configuration.me
        end

        opts.on_tail('--help', 'Show this help') do
          puts opts
          exit
        end
      end
      opts.parse!
      
      @options[:params][:owner] ||= PivotalShell::Configuration.me unless @options[:unowned] || @options[:anyone] || @options[:all]
      @options[:params][:state] ||= %w(unestimated unstarted started) unless @options[:all]
    end

    def execute
      stories = PivotalShell::Cache::Story.all(@options[:params])

      puts stories.empty? ? 'No stories!' : stories.map{|s| "#{("[#{s.id}]").rjust 12} #{PivotalShell::Configuration.icon(s.story_type, s.current_state, s.estimate)} #{s.name.strip}"}.join("\n")
    end
  end
end
