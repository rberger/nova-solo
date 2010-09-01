#
# Cookbook Name:: swift            
# Providers:: service
#
# Copyright 2010, Cloudscaling
#

action :setup do
  short_name = new_resource.name.sub(/-server/,'')

  directory "/etc/swift/#{new_resource.name}" do
    owner "swift"
    group "swift"
    recursive true
    mode 0755
  end  

  template "/etc/swift/#{new_resource.name}/#{new_resource.name}-#{new_resource.port}.conf" do
    cookbook "swift"
    source "server.conf.erb"
    mode 0644
    variables(
      :type => short_name,
      :devices => new_resource.devices,
      :port => new_resource.port,
      :username => "swift"
    )
    notifies :restart, resources(:swift_service => new_resource.name)
    backup false
  end

  directory "/var/run/swift/#{new_resource.name}" do
    owner "swift"
    group "swift"
  end

  if(new_resource.devices)
    directory new_resource.devices do
      owner "swift"
      group "swift"
    end
  end

  template "/etc/init.d/swift-#{new_resource.name}" do
    source "init-script.erb"
    mode 0755
    variables :server => new_resource.name
    backup false
  end

end

action :rebalance do
  short_name = new_resource.name.sub(/-server/,'')

  execute "rebalance-#{short_name}" do
    cwd "/etc/swift"
    command "/usr/local/bin/swift-ring-builder #{short_name}.builder rebalance"
    user "swift"
  end
end

action :start do
  short_name = new_resource.name.sub(/-server/,'')

  service "swift-#{new_resource.name}" do
    action :start
  end
end

action :stop do
  short_name = new_resource.name.sub(/-server/,'')

  service "swift-#{new_resource.name}" do
    action :stop
  end

end

action :build do
  short_name = new_resource.name.sub(/-server/,'')

  execute "build-#{new_resource.name}-ring" do
    user "swift"
    cwd "/etc/swift"
    command "/usr/local/bin/swift-ring-builder #{short_name}.builder create #{new_resource.part_power} #{new_resource.replicas} #{new_resource.min_part_hours}"
    creates "/etc/swift/#{short_name}.builder"
  end

  service "swift-#{new_resource.name}" do
    action :enable
  end
end

action :restart do
  execute "restart-#{new_resource.name}" do
    command "/usr/local/bin/swift-init #{new_resource.name} restart"
  end  
end
