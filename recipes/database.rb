include_recipe "postgresql::server"
include_recipe "database::postgresql"

postgresql_connection_info = {:host => "localhost",
                              :port => node['postgresql']['config']['port'],
                              :username => 'postgres',
                              :password => node['postgresql']['password']['postgres']}

# create a postgresql database
postgresql_database node.biodiv.database do
  connection postgresql_connection_info
  action :create
end

# create a postgresql user but grant no privileges
postgresql_database_user node['biodiv']['database-user'] do
  connection postgresql_connection_info
  password node['biodiv']['database-password']
  action :create
end


# setup postgis extension
# Vacuum a postgres database
postgresql_database 'create postgis extension' do
  connection      postgresql_connection_info
  database_name node.biodiv.database
  sql "CREATE EXTENSION if not exists postgis; CREATE EXTENSION if not exists postgis_topology; CREATE EXTENSION if not exists dblink;create or replace view observation_locations as SELECT obs.id, 'observation:'::text || obs.id AS source, r.name AS species_name, obs.topology, obs.last_revised FROM observation obs, recommendation r WHERE obs.max_voted_reco_id = r.id AND obs.is_deleted = false AND obs.is_showable = true;"
  action :nothing
end

# grant all privileges on all tables in foo db
postgresql_database_user node['biodiv']['database-user'] do
  connection postgresql_connection_info
  database_name node.biodiv.database
  privileges [:all]
  action :grant
  notifies :query, "postgresql_database[create postgis extension]"
end

