#
# Cookbook Name:: nova            
# Recipe:: volumestore

%w{xfsprogs vblade-persist lvm2}.each do |pkg_name|
  package pkg_name
end

execute "build-volumestore-device" do
  command "dd if=/dev/zero of=/tmp/volumestore bs=1M seek=1000 count=0" 
  not_if { File.exists?("/tmp/volumestore") }
end

execute "associate-nova-loopback" do
  command "losetup /dev/loop0 /tmp/volumestore" 
  not_if { `losetup -a` =~ /volumestore/ }
end

execute "build-novafs-fs" do
  command "mkfs.xfs -i size=1024 /dev/loop0"
  not_if 'xfs_admin -u /dev/loop0'
end

directory "/mnt/sdb1" do 
  mode "0755"
  owner "root"
  group "root"
end

execute "update fstab" do
  command "echo '/dev/loop0 /mnt/sdb1 xfs noauto,noatime,nodiratime,nobarrier,logbufs=8 0 0' >> /etc/fstab"
  not_if "grep '/dev/loop0' /etc/fstab"
end

execute "mount /mnt/sdb1" do
  not_if "df | grep /dev/loop0"
end

##########################################################################
# Nova-volume.conf is "broken" in the nova-volume package. I will
# supply my own conf prior to installing the package
##########################################################################
template "/etc/nova/nova-volume.conf" do
  source "nova-volume.conf.erb"
end

##########################################################################
# Since I am supplying my own nova-volume.conf I need to instruct
# apt-get to use the file on the disk and not override it with the
# one in the package
##########################################################################
package "nova-volume" do
  options "-o Dpkg::Options::=\"--force-confold\""
end

service "nova-volume" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
