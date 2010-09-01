#
# Cookbook Name:: nova            
# Recipe:: default

include_recipe "apt"

##########################################################################
# We'll use Soren's repository since it contains all the required 
# packages
##########################################################################
execute "Download Soren's Launchpad GPG key" do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys AB0188513FD35B23" 
  not_if { `gpg -a --export AB0188513FD35B23` =~ /BEGIN PGP/ }
end

execute "Import Soren's Launchpad GPG key" do
  command "gpg -a --export AB0188513FD35B23 | apt-key add -"
  not_if { `apt-key list` =~ /3FD35B23/ }
end

template "/etc/apt/sources.list.d/soren-nova.list" do
  source "soren-nova.list.erb"
#  variables ( {
#    :url1 => "http://192.168.122.1/repos/ppa.launchpad.net/soren/nova/ubuntu",
#    :url2 => "http://192.168.122.1/repos/173.203.107.207/ubuntu"
#  } )
  variables ( {
    :url1 => "http://ppa.launchpad.net/soren/nova/ubuntu",
    :url2 => "http://173.203.107.207/ubuntu"
  } )
  notifies :run, resources(:execute => "apt-get update"), :immediate
end


# Install common Nova packages
%w{python-mox screen euca2ools unzip parted python-setuptools python-dev python-pycurl python-m2crypto strace}.each do |pkg_name|
  package pkg_name
end

# Disable Apparmor since it can really mess with us
service "apparmor" do
  action :disable
end

include_recipe "nova::controller"
include_recipe "nova::objectstore"
include_recipe "nova::api"
include_recipe "nova::volumestore"
include_recipe "nova::compute"