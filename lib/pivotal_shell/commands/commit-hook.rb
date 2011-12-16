module PivotalShell::Commands
  class PivotalShell::Commands::CommitHook < PivotalShell::Command
    def initialize(options)
      @filename = options.first
      @commit_message = File.read(@filename)
    end

    def execute
      STDIN.reopen('/dev/tty') unless STDIN.tty?
      begin
        @stories = PivotalShell::Cache::Story.all(:owner => PivotalShell::Configuration.me, :state => %w(unstarted started))
        @stories.each do |story|
          puts "#{highlighted_id(story.id).rjust(12)} #{story.name}"
        end
        puts @error_message if @error_message
        print 'Story number / (R)efresh / (A)bort>'
        response = gets.chomp
        case response
        when 'R', 'r':
          puts 'Refreshing list of stories from server...'
          PivotalShell::Configuration.cache.refresh
        when 'A', 'a':
          @exit = true
        when /(\d+)(!?)/
          @bang = $2=='!'
          selected_stories = find_stories_by_id_fragment($1)
          if selected_stories.empty?
            @error_message = 'No story matches this ID'
          elsif selected_stories.length==1
            @story = selected_stories.first
            @exit = true
          else
            @error_message = 'More than one matching story. Print at least the highlighted part of the ID, please'
          end
        end
        puts
      end while !@exit

      if @story
        print %Q{Confirm attaching commit to story "#{@story.name}" [Yn]:}
        answer = File.open('/dev/tty','r').gets.chomp
        if answer=='' || (answer[0,1].downcase == 'y')
          puts "COMMIT MESSAGE"
        end
      end
      exit 1
    end

  protected
    def unique_fragment_length(id)
      ids = @stories.map(&:id).map(&:to_s)
      1.upto(id.length) { |i|
        fragment = id[-i..-1]
        if @stories.select{|s| s.id.to_s[-i..-1]==fragment}.length==1
          return i
        end
      }
      return id.length
    end

    def find_stories_by_id_fragment(id)
      @stories.select{|story| story.id.to_s =~ /#{id}\Z/}
    end

    def highlighted_id(id)
      id = id.to_s
      length = unique_fragment_length(id)
      '['+id[0..-(length-1)] + 
        $terminal.color(id[-length..-1], :yellow) + 
        ']'
    end
  end
end
