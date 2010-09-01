#
# Cookbook Name:: nova            
# Recipe:: controller


%w{nginx rabbitmq-server redis-server}.each do |pkg_name|
  package pkg_name
end


service "nginx" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
  running true
end

service "rabbitmq-server" do
  supports :restart => true, :status => true, :reload => true
  action [ :enable, :start ]
  running true
end

service "redis-server" do
  supports :restart => true
  action [ :enable, :start ]
  running true
end

template "/etc/redis/redis.conf" do
  source "redis.conf.erb"
  notifies :restart, resources(:service => "redis-server")
  owner "redis"
  group "redis"
end
