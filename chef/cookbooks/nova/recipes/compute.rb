#
# Cookbook Name:: nova            
# Recipe:: compute

##########################################################################
# Make sure the qemu network dir exists
##########################################################################
#%w{/etc/libvirt/qemu/networks /var/lib/libvirt/network}.each do |dir_name|
%w{/etc/libvirt/qemu/networks}.each do |dir_name|
  directory dir_name do
  owner "root"
  group "root"
  mode 0755
  recursive true
  end
end

##############################################################################
# Need to change virbr0 IP from 192.168.122.x since it clashes with eth0
# if we are running the dev box within 
##############################################################################
#%w{/etc/libvirt/qemu/networks/default.xml /var/lib/libvirt/network/default.xml}.each do |file|
%w{/etc/libvirt/qemu/networks/default.xml}.each do |file|
template file do
    source "qemu-networks-default.xml.erb"
    variables ( {
                 :ip_prefix => "192.168.200"
                } )
  end
end

package "libvirt-bin" do
  options "-o Dpkg::Options::=\"--force-confold\""
end

service "libvirt-bin" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  running true
end
  
%w{nova-compute python-libvirt kpartx kvm}.each do |pkg_name|
  package pkg_name
end

  
#execute "Install libvirt-bin" do
#  execute "echo y | apt-get -y install libvirt-bin"
#end

# If we are running in a VM switch KVM for QEMU
if ( node[:virtualization][:role] == "guest" )
  template "/usr/share/nova/libvirt.xml.template" do
    source "libvirt.xml.template.erb"
    owner "root"
    group "root"
    mode 0644
  end
end

service "nova-compute" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  running true
end

execute "Add Redis Server location to Nova Compute" do
  command "echo --redis_host=" + node.default[:nova][:redis][:hostname] + " >> /etc/nova/nova-compute.conf" 
  not_if { `cat /etc/nova/nova-compute.conf` =~ /--redis_host=#{node.default[:nova][:redis][:hostname]}/ }
  notifies :restart, resources(:service => "nova-compute")
end


execute "Add RabbitMQ Server location to Nova Compute" do
  command "echo --rabbit_host=" + node.default[:nova][:rabbit][:hostname] + " >> /etc/nova/nova-compute.conf" 
  not_if { `cat /etc/nova/nova-compute.conf` =~ /--rabbit_host=#{node.default[:nova][:rabbit][:hostname]}/ }
  notifies :restart, resources(:service => "nova-compute")
end

