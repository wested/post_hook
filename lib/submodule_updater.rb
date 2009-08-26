#############################################################
#
# WEI Post Hook
# Last updated: August 26, 2009
# Maintained by: 
#   Bob Burbach, bburbac@wested.org
#   Github: Peregrinator
#
#############################################################
class SubmoduleUpdater < GithubServiceHook
  def initialize(params, options={})
    super
  end
  
  def update_submodule
    `cd #{@module_path} && git checkout #{@branch} && git pull`
  end
  
  def write_to_file(file)
    file_path = "tmp/#{file}"
    `touch #{file_path}`
    `echo "#{@repository['name']}" > #{file_path}`
  end
end