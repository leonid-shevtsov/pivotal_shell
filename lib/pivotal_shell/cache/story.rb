class PivotalShell::Cache
  class Story
    ATTRIBUTES=%w(requested_by_id name id current_state accepted_at labels url estimate description created_at owned_by_id story_type)
    STATUSES = %w(unscheduled unstarted started finished delivered accepted rejected)
    TYPES = %w(feature bug chore)
    
    ATTRIBUTES.each do |attribute|
      attr_reader attribute
    end

    def initialize(source={})
      if source.is_a? PivotalTracker::Story
        raise 'TODO'
      elsif source.is_a? Hash
        create_from_hash(source)
      end
    end

    def self.find(id)
      hash = PivotalShell::Configuration.cache.db.execute("SELECT * FROM stories WHERE id=?", id).first
      hash && new(hash)
    end

    def self.all(params)
      conditions = []
      query_params = []
      if params[:unowned]
        conditions << "owned_by_id IS NULL"
      elsif params[:owner] && (owner = PivotalShell::Cache::User.find(params[:owner]))
        conditions << "owned_by_id==?"
        query_params << owner.id
      end
      
      if params[:state]
        params[:state] = [params[:state]].flatten
        conditions << "current_state IN (#{(["?"]*params[:state].length).join(',')})"
        query_params << params[:state]
      end

      if params[:type]
        params[:type] = [params[:type]].flatten
        conditions << "story_type IN (#{(["?"]*params[:type].length).join(',')})"
        query_params << params[:type]
      end

      query = 'SELECT * FROM stories'
      query << ' WHERE '+conditions.map{|c| "(#{c})"}.join(' AND ') unless conditions.empty?
      PivotalShell::Configuration.cache.db.execute(query, query_params).map {|r| new(r)}
    end

    def owned_by
      return nil if owned_by_id.nil?
      @owned_by ||= PivotalShell::Cache::User.find(owned_by_id)
    end

    def requested_by
      return nil if requested_by_id.nil?
      @requested_by ||= PivotalShell::Cache::User.find(requested_by_id)
    end

  protected
    def create_from_hash(hash)
      PivotalShell::Cache::Story::ATTRIBUTES.each do |attribute|
        self.instance_variable_set("@#{attribute}", hash[attribute])
      end
    end
  end
end
