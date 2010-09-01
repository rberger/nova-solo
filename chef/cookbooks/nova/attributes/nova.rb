#
# Cookbook Name:: nova
# Attributes:: nova
#


default[:nova][:redis][:hostname] = node[:ipaddress]
default[:nova][:rabbit][:hostname] = node[:ipaddress]
