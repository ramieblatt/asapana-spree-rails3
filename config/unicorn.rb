APP_ROOT="/var/www/asapana"
worker_processes 2
working_directory "#{APP_ROOT}/"
preload_app true
timeout 60
listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", :backlog => 128

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

pid "#{APP_ROOT}/tmp/pids/unicorn.pid"
stderr_path "#{APP_ROOT}/log/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn.stout.log"
before_fork do |server, worker|
 old_pid = APP_ROOT + '/tmp/pids/unicorn.pid.oldbin'
 if File.exists?(old_pid) && server.pid != old_pid
     begin
       Process.kill("QUIT", File.read(old_pid).to_i)
     rescue Errno::ENOENT, Errno::ESRCH
       # someone else did our job for us
     end
 end
 defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
 defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
 begin
   #Rails.cache.reconnect
   uid, gid = Process.euid, Process.egid
   user, group = 'asapana', 'www-data'
   target_uid = Etc.getpwnam(user).uid
   target_gid = Etc.getgrnam(group).gid
   worker.tmp.chown(target_uid, target_gid)
   if uid != target_uid || gid != target_gid
     Process.initgroups(user, target_gid)
     Process::GID.change_privilege(target_gid)
     Process::UID.change_privilege(target_uid)
   end
 rescue => e
   if RAILS_ENV == 'development'
     STDERR.puts "couldn't change user, oh well"
   else
     raise e
   end
 end
 
end










