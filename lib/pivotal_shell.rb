require 'pivotal_tracker'

module PivotalShell
  class Exception < StandardError; end
end

require 'pivotal_shell/version'
require 'pivotal_shell/configuration'
require 'pivotal_shell/cache'
require 'pivotal_shell/command'

# fixing pivotal-tracker's options encoding; it did not work with array filters
module PivotalTracker
  class <<self
    def encode_options(options)
      return nil if !options.is_a?(Hash) || options.empty?
      options_strings = []
      # remove options which are not filters, and encode them as such
      [:limit, :offset].each do |o|
        options_strings << "#{CGI.escape(o.to_s)}=#{CGI.escape(options.delete(o).to_s)}" if options[o]
      end
      # assume remaining key-value pairs describe filters, and encode them as such.
      filters_string = options.map do |key, value|
        "#{CGI.escape(key.to_s)}%3A#{CGI.escape([value].flatten.map{|v| v=v.to_s; v.include?(' ') ? '"'+v+'"' : v}.join(','))}"
      end
      options_strings << "filter=#{filters_string.join('+')}" unless filters_string.empty?
      return "?#{options_strings.join('&')}"
    end
  end
end
