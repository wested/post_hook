#############################################################
#
# WEI Post Hook
# Last updated: August 26, 2009
# Maintained by: 
#   Bob Burbach, bburbac@wested.org
#   Github: Peregrinator
#
#############################################################
require 'yaml'

class PostHook
  def initialize(params)
    
    # load config for this app
    location = "#{File.dirname(__FILE__)}/../config/config.yml"
    if !File.exist?(location)
      raise "You must configure your app in config/config.yml!"
    else
      config = YAML.load( File.open(location, 'r') )
    end
    @app_path    = config['post_hook']['app_path']
    @module_path = config['post_hook']['module_path']
    @server_name = config['post_hook']['server_name']
  end
end