class Notification
  
  def initialize(update_details)
    @update_details = update_details
    
    # load config for notifications
    location = "#{File.dirname(__FILE__)}/../config/config.yml"
    if !File.exist?(location)
      raise "You must configure your app in config/config.yml!"
    else
      config = YAML.load( File.open(location, 'r') )
    end
    
    @notify_of_errors     = config['notifications']['notify_of_errors']
    @notify_of_success    = config['notifications']['notify_of_success']
    @yammer_notifications = config['notifications']['yammer_notifications']
  end
  
  def deliver!
    deliver_email
    # if @yammer_notifications
    #   send_yammer
    # end
  end
  
  private
  
  def send_yammer
    
  end
  
  def deliver_email
    if !@update_details.exit_status.nil? && @update_details.exit_status.to_i == 0
      email_message = build_success_message
      recipients    = @notify_of_success
    else
      email_message = build_error_message
      recipients    = @notify_of_errors
    end
    stderr_message = nil
    stdout_message = nil
    status = 
       POpen4::popen4("mail -s '[#{@update_details.current_server}] Submodule Update for #{@update_details.submodule_path}' #{recipients}") do |stdout, stderr, stdin, pid|
         stdin.puts email_message
         stdin.close
         
         stderr_message = stderr.read.strip
         stdout_message = stdout.read.strip
       end
    
    exit_status    = status.exitstatus
    return_message = exit_status != 0 ? stderr_message : stdout_message
  end
  
  def build_yammer_error_message
    <<-EOF
      Submodule #{@update_details.submodule_path} attempted an update at #{@update_details.updated_at} 
      on #{@update_details.current_server} via PostHook. The result was an error #{@update_details.exit_status} 
      with message #{@update_details.return_message}.
    EOF
  end
  
  def build_yammer_success_message
    <<-EOF
      Submodule #{@update_details.submodule_path} was updated at #{@update_details.updated_at} 
      on #{@update_details.current_server} by #{@update_details.author} via PostHook
    EOF
  end
  
  def build_error_message
    <<-EOF
      Submodule #{@update_details.submodule_path} attempted an update at #{@update_details.updated_at} 
      on #{@update_details.current_server} via PostHook. The result was an error #{@update_details.exit_status} 
      with message #{@update_details.return_message}.
    EOF
  end
  
  def build_success_message
    <<-EOF
      A new version of submodule #{@update_details.submodule_path} has been updated at #{@update_details.updated_at}. \n\n
      
      Branch: #{@update_details.submodule_branch}
      Updated From: #{@update_details.updated_from} \n
      Updated To: #{@update_details.updated_to} \n
      
      The branch was updated by #{@update_details.author} on #{@update_details.timestamp}.
      The commit message was #{@update_details.message}.
      The files update were #{@update_details.added.join(',')}
      
      This message orignated from the #{@update_details.current_server} at #{Time.now}
    EOF
  end
end