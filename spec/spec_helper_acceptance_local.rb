# frozen_string_literal: true

require 'net/http'
require 'nokogiri'
require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

CHOCOLATEY_LATEST_INFO_URL = 'https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/choco-pipeline-tests/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion'

def encode_command(cmd)
  cmd = cmd.chars.to_a.join("\x00").chomp
  cmd << "\x00" unless cmd[-1].eql? "\x00"
  # use strict_encode because linefeeds are not correctly handled in our model
  cmd = Base64.strict_encode64(cmd).chomp
  cmd
end

def install_chocolatey
  chocolatey_pp = <<-MANIFEST
    include chocolatey
  MANIFEST

  LitmusHelper.instance.apply_manifest(chocolatey_pp, catch_failures: true)
end

def config_file_location
  'c:\\ProgramData\\chocolatey\\config\\chocolatey.config'
end

def backup_config
  bolt_run_script(File.expand_path('spec/support/scripts/backup_config.ps1', Dir.pwd))
end

def reset_config
  bolt_run_script(File.expand_path('spec/support/scripts/reset_config.ps1', Dir.pwd))
end

def get_xml_value(xpath, file_text)
  doc = Nokogiri::XML(file_text)

  doc.xpath(xpath)
end

def config_content_command
  "cmd.exe /c \"type #{config_file_location}\""
end

RSpec.configure do |c|
  c.include_context 'backup and reset config', include_shared: true
  c.before(:suite) {
  git_pp = <<-MANIFEST
  package { 'git':
  ensure   => 'latest',
}
MANIFEST

#LitmusHelper.instance.apply_manifest(git_pp, catch_failures: true)
    LitmusHelper.instance.run_shell('C:\"Program Files"\"Puppet Labs"\Puppet\puppet\bin\gem.bat install retriable', expect_failures: true)
    LitmusHelper.instance.run_shell('C:\"Program Files"\"Puppet Labs"\Puppet\puppet\bin\gem.bat install git', expect_failures: true)
    LitmusHelper.instance.run_shell('C:\"Program Files"\"Puppet Labs"\Puppet\puppet\bin\gem.bat install pry', expect_failures: true)
    LitmusHelper.instance.run_shell('cd C:\ProgramData\PuppetLabs\code\environments\production\modules;git init;git submodule add https://github.com/sheenaajay/opv.git opv;cd opv;git checkout testingissue3;', expect_failures: true)
    install_chocolatey
  }
end
