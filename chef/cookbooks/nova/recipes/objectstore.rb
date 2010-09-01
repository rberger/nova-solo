#
# Cookbook Name:: nova            
# Recipe:: objectstore


%w{nova-objectstore}.each do |pkg_name|
  package pkg_name
end

service "nova-objectstore" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  running true
end