include_attribute "tomcat"

expand!

default[:biodiv][:version]   = "master"
default[:biodiv][:appname]   = "biodiv"
default[:biodiv][:directory] = "/usr/local/src"

default[:biodiv][:link]      = "https://codeload.github.com/strandls/biodiv/zip/#{biodiv.version}"
default[:biodiv][:extracted] = "#{biodiv.directory}/biodiv-#{biodiv.version}"
default[:biodiv][:war]       = "#{biodiv.extracted}/target/biodiv.war"
default[:biodiv][:download]  = "#{biodiv.directory}/biodiv-#{biodiv.version}.zip"

default[:biodiv][:home] = "/usr/local/biodiv"


# mail server
default[:biodiv][:smtphost] = "127.0.0.1"
default[:biodiv][:smtpport] = 25
