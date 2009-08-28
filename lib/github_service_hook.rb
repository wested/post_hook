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

class GithubServiceHook < PostHook
  def initialize(params)
    super
    
    # see README for example github service hook JSON description
    @before     = params['before']
    @after      = params['after']
    @ref        = params['ref']
    @commits    = params['commits']
    @repository = params['repository']
    
    # load config for this repository
    @repo_name = @repository['name']
    location = "#{File.dirname(__FILE__)}/../config/submodules.yml"
    if !File.exist?(location)
      raise "You must configure your submodule in config/submodules.yml!"
    else
      config = YAML.load( File.open(location, 'r') )
    end
    repo_config = config['submodules']["#{@repo_name}"]
    raise "#{@repo_name} is not configured!" if repo_config.nil?
    
    # change submodule path from default if the repo config defines it
    if repo_config['module_path']
      @module_path = repo_config['module_path']
    end
    
    @submodule_path = @app_path + @module_path + @repo_name
    
    @submodule_branch = repo_config['branch']
  end
  
end