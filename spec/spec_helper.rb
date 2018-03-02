require 'pry' if Bundler.rubygems.find_name('pry').any?
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rake'
require 'fileutils'
require 'beaker-rspec'

RSpec.configure do |c|
  # set the environment variable before files are loaded, otherwise it is too late
  ENV['ChocolateyInstall'] = 'c:\blah'

  begin
    Win32::Registry.any_instance.stubs(:[]).with('Bind')
    Win32::Registry.any_instance.stubs(:[]).with('Domain')
    Win32::Registry.any_instance.stubs(:[]).with('ChocolateyInstall').raises(Win32::Registry::Error.new(2), 'file not found yo')
  rescue
    # we don't care
  end

  # https://www.relishapp.com/rspec/rspec-core/v/2-12/docs/mock-framework-integration/mock-with-mocha!
  c.mock_framework = :mocha
  # see output for all failures
  c.fail_fast = false
  c.expect_with :rspec do |e|
    e.syntax = [:should, :expect]
  end
  c.raise_errors_for_deprecations!

  c.after :suite do
    #result = RubyProf.stop
    # Print a flat profile to text
    #printer = RubyProf::FlatPrinter.new(result)
    #printer.print(STDOUT)
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias :must :should
  alias :must_not :should_not
end
