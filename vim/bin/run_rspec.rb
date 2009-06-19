spec_dir=File.expand_path File.dirname(ARGV[0])
rails_project_dir=spec_dir.gsub(/(.+)\/spec.*/, '\1')

report_file="#{rails_project_dir}/doc/rspec_report.html"

rspec_rails_plugin = File.join(rails_project_dir,'vendor','plugins','rspec','lib')
if File.directory?(rspec_rails_plugin)
  $LOAD_PATH.unshift(rspec_rails_plugin)
end
require 'rubygems'
require 'spec'
require 'spec/runner/formatter/html_formatter'

module Spec
  module Runner
    module Formatter
      class HtmlFormatter
        def backtrace_line(line)
          line.gsub(/([^:]*\.rb):(\d*)/) do
            "<a href=\"vim://#{File.expand_path($1)}?#{$2}\">#{$1}:#{$2}</a> "
          end
        end
      end
    end
  end
end

if File.exists? report_file
  File.delete report_file
end

argv = [ARGV[0]]
argv << "--drb"
argv << "--c"
argv << "--format"
argv << "html:#{report_file}"

begin
  ::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(argv, STDERR, STDOUT))
rescue Exception => e
  File.open("#{report_file}", "w") do |file|
    message = e.message.split("\n").collect do |m|
      "<a href=\"vim://#{m.gsub(/rb:/, 'rb?')}\">#{m}</a>"
    end
    file.write("#{message.join("<br />")} <br />")
    linkable_traces = e.backtrace.collect do |traceline|
      "<a href=\"vim://#{traceline.gsub(/:/, '?')}\">#{traceline}</a>"
    end
    file.write linkable_traces.join("<br />")
  end
end
if File.exists? report_file
  `open -a /Applications/Firefox2/Firefox.app #{report_file}`
end
