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
  def initialize(params)
    super
  end
  
  def update
    update_details = update_submodule
    notify(update_details)
  end
  
  private
  
  def notify(update_details)
    notification = Notification.new(update_details)
    notification.deliver!
  end
  
  def update_submodule
    update_details = OpenStruct.new
    update_details.exit_status    = nil
    update_details.return_message = "Nothing to update"
    
    branch_updated  = @ref.split('/').last
    if @submodule_branch == branch_updated
      initiate_update_at = Time.now
      previous_commit = `cd #{@app_path} && git submodule status #{@module_path + @repo_name}`.split(' ').first
      latest_commit   = @commits.first['id']
      if previous_commit != latest_commit
        
        stderr_message = nil
        stdout_message = nil
        status = 
           POpen4::popen4("cd #{@app_path} && git submodule update #{@module_path + @repo_name} --merge") do |stdout, stderr, stdin, pid|
             stderr_message = stderr.read.strip
             stdout_message = stdout.read.strip
           end
        
        exit_status    = status.exitstatus
        return_message = exit_status != 0 ? stderr_message : stdout_message
      else
        return_message = "Submodule was already up to date."
      end
      finish_update_at = Time.now
      
      update_details.submodule_branch = @submodule_branch
      update_details.submodule_path   = @submodule_path
      update_details.branch_updated   = branch_updated
      update_details.initiated_at     = initiate_update_at
      update_details.finished_at      = finish_update_at
      update_details.updated_from     = previous_commit
      update_details.updated_to       = latest_commit
      update_details.exit_status      = exit_status
      update_details.return_message   = return_message
      update_details.author           = @commits.first['author']['name']
      update_details.message          = @commits.first['message']
      update_details.timestamp        = @commits.first['timestamp']
      update_details.added            = @commits.first['added']
      update_details.current_server   = @server_name
      
      log_submodule_update(update_details)
    end
    
    return update_details
  end
  
  def log_submodule_update(update_details)
    Log.info "\n\nUpdating submodule #{update_details.submodule_path}"
    Log.info "Initiated at: #{update_details.initiated_at}"
    Log.info "My Branch: #{update_details.submodule_branch}"
    Log.info "Branch updated: #{update_details.branch_updated}"
    Log.info "My previous commit was: #{update_details.updated_from}"
    Log.info "Updating to commit: #{update_details.updated_to}"
    Log.info "Status code returned from submodule update: #{update_details.exit_status}"
    Log.info "Return message from submodule update: #{update_details.return_message}"
    Log.info "Finished at: #{update_details.finished_at}"
  end
end