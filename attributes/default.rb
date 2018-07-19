expand!

default[:biodiv][:version]   = "master"
default[:biodiv][:appname]   = "biodiv"
default[:biodiv][:repository]   = "biodiv"
default[:biodiv][:directory] = "/usr/local/src"

default[:biodiv][:link]      = "https://codeload.github.com/strandls/#{biodiv.repository}/zip/#{biodiv.version}"
default[:biodiv][:extracted] = "#{biodiv.directory}/biodiv-#{biodiv.version}"
default[:biodiv][:war]       = "#{biodiv.extracted}/target/biodiv.war"
default[:biodiv][:download]  = "#{biodiv.directory}/#{biodiv.repository}-#{biodiv.version}.zip"

default[:biodiv][:home] = "/usr/local/biodiv"

default[:biodivApi][:version]   = "master"
default[:biodivApi][:appname]   = "biodiv-api"
default[:biodivApi][:configname]   = "BIODIV_API_CONFIG"
default[:biodivApi][:repository]   = "biodiv-api"
default[:biodivApi][:directory] = "/usr/local/src"

default[:biodivApi][:link]      = "https://codeload.github.com/strandls/#{biodivApi.repository}/zip/#{biodivApi.version}"
default[:biodivApi][:extracted] = "#{biodivApi.directory}/#{biodivApi.appname}-#{biodivApi.version}"
default[:biodivApi][:war]       = "#{biodivApi.extracted}/build/libs/#{biodivApi.appname}.war"
default[:biodivApi][:download]  = "#{biodivApi.directory}/#{biodivApi.repository}-#{biodivApi.version}.zip"

default[:biodivApi][:home] = "/usr/local/biodivApi"

default[:biodivApi][:additional_config] = "#{biodivApi.extracted}/#{biodivApi.appname}.properties"

# mail server
default[:biodiv][:smtphost] = "127.0.0.1"
default[:biodiv][:smtpport] = 25
default[:biodiv][:tomcat_instance]    = "biodiv"
default[:biodiv][:additional_config] = "#{biodiv.extracted}/#{node.biodiv.appname}-additional-config.groovy"
