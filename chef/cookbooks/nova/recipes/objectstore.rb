#
# Cookbook Name:: nova            
# Recipe:: objectstore


%w{nova-objectstore}.each do |pkg_name|
  package pkg_name
end

# With 0.9.1 packages this doesn't work properly. Commenting out for now
#service "nova-objectstore" do
#  supports :status => true, :restart => true
#  action [ :enable, :start ]
#  running true
#end
