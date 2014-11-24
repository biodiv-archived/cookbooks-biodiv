#
# Cookbook Name:: biodiv
# Recipe:: default
#
# Copyright 2014, Strand Life Sciences
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


include_recipe "tomcat"
include_recipe "application"

# setup solr
include_recipe "solr-tomcat" 

# setup geoserver
include_recipe "geoserver-tomcat" 
include_recipe "geoserver-tomcat::postgresql"

# setup biodiversity nameparser
include_recipe "biodiversity-nameparser"

# setup biodiv database 
include_recipe "biodiv::database"

# install nginx 
include_recipe "nginx"

# setup postfix
include_recipe "postfix"

# install apt utility packages
apt_package "imagemagick" do
  action :install
end

apt_package "gdal-bin" do
  action :install
end

apt_package "libgeoip1" do
  action :install
end

apt_package "libgtk2.0" do
  action :install
end

apt_package "libproj-dev" do
  action :install
end

apt_package "binutils" do
  action :install
end

apt_package "jpegoptim" do
  action :install
end

apt_package "ntp" do
  action :install
end

apt_package "mailutils" do
  action :install
end

# create includes folder
directory "#{node['nginx']['dir']}/include.d/" do
  owner node.nginx.user
  group node.nginx.group
  action :create
end

#  setup nginx biodiv conf
template "#{node['nginx']['dir']}/include.d/#{node.biodiv.appname}" do
  source "nginx-biodiv.erb"
  owner node.nginx.user
  group node.nginx.group
  notifies :restart, resources(:service => "nginx"), :immediately
end

#  setup nginx main conf
template "#{node['nginx']['dir']}/sites-enabled/#{node.biodiv.appname}-main.conf" do
  source "nginx-wikwio.erb"
  owner node.nginx.user
  group node.nginx.group
  notifies :restart, resources(:service => "nginx"), :immediately
end

# install grails
include_recipe "grails-cookbook"
grailsCmd = "#{node['grails']['install_path']}/bin/grails"
biodivRepo = "#{Chef::Config[:file_cache_path]}/biodiv"
additionalConfig = "#{node.biodiv.extracted}/#{node.biodiv.appname}-additional-config.groovy"

bash 'cleanup extracted biodiv' do
   code <<-EOH
   rm -rf #{node.biodiv.extracted}
   rm -f #{additionalConfig}
   EOH
   action :nothing
   notifies :run, 'bash[unpack biodiv]'
end

# download git repository zip
remote_file node.biodiv.download do
  source   node.biodiv.link
  mode     0644
  notifies :run, 'bash[cleanup extracted biodiv]',:immediately
end

bash 'unpack biodiv' do
  code <<-EOH
  cd "#{node.biodiv.directory}"
  unzip  #{node.biodiv.download}
  EOH
  not_if "test -d #{node.biodiv.extracted}"
  notifies :create, "template[#{additionalConfig}]",:immediately
  notifies :run, "bash[copy static files]",:immediately
end

bash 'copy static files' do
  code <<-EOH
  mkdir -p #{node.biodiv.data}/images
  cp -r #{node.biodiv.extracted}/web-app/images/* #{node.biodiv.data}/images
  chown -R #{node.tomcat.user}:#{node.tomcat.group} #{node.biodiv.data}
  EOH
  only_if "test -d #{node.biodiv.extracted}"
end

application node.biodiv.appname do
    path node.biodiv.home
    owner node["tomcat"]["user"]
    group node["tomcat"]["group"]
    repository node.biodiv.war
    revision     "HEAD"
    scm_provider Chef::Provider::File::Deploy

    java_webapp do
        context_template "biodiv.context.erb"
    end

    tomcat
end

# copy app-conf data
remote_directory "#{node.biodiv.data}/data" do
  source       "app-conf-data"
  owner        node.tomcat.user
  group        node.tomcat.group
  files_owner  node.tomcat.user
  files_group  node.tomcat.group
  files_backup 0
  files_mode   "644"
  purge        true
  action       :create_if_missing
  recursive true
  notifies :run, "execute[change-permission-#{node.biodiv.data}]", :immediately
  not_if       { File.exists? "#{node.biodiv.data}/data/datarep" }
end

execute "change-permission-#{node.biodiv.data}" do
  command "chown -R #{node.tomcat.user}:#{node.tomcat.group} #{node.biodiv.data}"
  user "root"
end

bash "compile_biodiv" do 
  code <<-EOH
  cd #{node.biodiv.extracted}
  yes | #{grailsCmd} upgrade
  export BIODIV_CONFIG_LOCATION=#{additionalConfig}
  yes | #{grailsCmd} -Dgrails.env=kk war 
  chmod +r #{node.biodiv.war}
  EOH

  not_if "test -f #{node.biodiv.war}"
  only_if "test -f #{additionalConfig}"
  notifies :run, "bash[copy additional config]", :immediately
end

bash "copy additional config" do
 code <<-EOH
  mkdir -p /tmp/biodiv-temp/WEB-INF/lib
  mkdir -p ~#{node.tomcat.user}/.grails
  cp #{additionalConfig} ~#{node.tomcat.user}/.grails
  cp #{additionalConfig} /tmp/biodiv-temp/WEB-INF/lib
  cd /tmp/biodiv-temp/
  jar -uvf #{node.biodiv.war}  WEB-INF/lib
  chmod +r #{node.biodiv.war}
  #rm -rf /tmp/biodiv-temp
  EOH
  notifies :deploy, "application[#{node.biodiv.appname}]", :immediately
  action :nothing
end

#  create additional-config
template additionalConfig do
  source "additional-config.groovy.erb"
  notifies :run, "bash[compile_biodiv]"
  notifies :run, "bash[copy additional config]"
end

