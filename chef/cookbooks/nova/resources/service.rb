#
# Cookbook Name:: swift            
# Resources:: service
#
# Copyright 2010, Cloudscaling
#

actions :setup, :start, :stop, :restart, :build, :rebalance

attribute :port, :kind_of => Integer, :required => true
attribute :devices, :kind_of => String
attribute :part_power, :kind_of => Integer, :default => 18
attribute :replicas, :kind_of => Integer, :default => 3
attribute :min_part_hours, :kind_of => Integer, :default => 1
