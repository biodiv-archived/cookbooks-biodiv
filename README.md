biodiv Cookbook
=============

Installs and configures biodiv the generic biodiversity informatics
platform. The platform servers the need for sourcing and aggregating
biodiversity information and providing the information in the public
domain. It provide open access to all biodoiversity information under
the creative commons license with clear attribution to the
contributor. The platform can be used for a country, region or group.
There are currently three portals running on the codebase:

* [India Biodiversity Portal](http://indiabiodiversity.org)
* [Bhutan Biodiversity Portal](http://biodiversity.bt)
* [WIKWIO Biodiversity Portal](http://portal.wikwio.org)

The biodiv platform has an well-integrated set of modules required for
biodiversity information:

* An observation module for citizen science and to crowd source biodiversity information
* A species pages module with one page for every species conforming to the TDWG standards of the Species Profile Model (SPM)
* A fully featured web-GIS module
* A document module for documents and reports
* A discussion forum

Requirements
============

## Hardware
    Quad core processor. (Tested on Intel(R) Xeon(R) CPU E3110 @ 3.00GHz)
    RAM at least 4GB 
    HDD at least 160 GB

## Platforms

* Ubuntu 14.04 LTS (64 bit recommended)

Tested on:

* Ubuntu 14.04 LTS (64 bit)

### Cookbooks
Requires the following cookbooks

* `grails-cookbook`
* `database`
* `postgresql`
* `application`
* `application_java`
* `nginx`
* `geoserver-tomcat` [Source](https://github.com/strandls/cookbooks-geoserver-tomcat)
* `solr-tomcat`      [Source](https://github.com/strandls/cookbooks-solr-tomcat)
* `biodiversity-nameparser` [Source](https://github.com/strandls/cookbooks-biodiversity-nameparser)
* `postfix`


Attributes
============

* `node[:biodiv][:version]` - The branch / version of biodiv to install. E.g. master, wikwio
* `node[:biodiv][:appname]` - The context path / name of the installed app on tomcat.
* `node[:biodiv][:servername]` - The public FQDN through which biodiversity postal is accessed.
* `node[:biodiv][:directory]` - Working directory where biodiv code is extracted and war created.
* `node[:biodiv][:home]` - The folder hosting biodiv war files, used by tomcat.
* `node[:biodiv][:smtphost]` - The smtp host to route outgoing mails. Defaults to localhost.
* `node[:biodiv][:smtpport]` - The smtp host port. Defaults to 25.
* `node[:biodiv][:data]` - The folder where biodiv app should store files like observation images.
* `node[:biodiv][:augmentedmaps]` - The folder where biodiv stores map data files. 

## Postgresql related attributes
* `node[:biodiv][:database]` - The name of the postgresql database.
* `node[:biodiv][:database-user]` - The name of the database user.
* `node[:biodiv][:database-password]` - The password for the database user.

The default values for these attributes can be found in `attributes/default.rb`

This cookbook relies on the following 
* nginx - Nginx serves static content for biodiversity and proxies dynamic content requests to tomcat. Required nginx configuration is shown in example usage below. More configuration can be found [here](https://github.com/miketheman/nginx).
* postfix -  Postfix configuration options can be found [here][https://github.com/opscode-cookbooks/postfix].
* tomcat - The require catalina_options are as shown in the usage note below. You could tweak the overall memory allocated to tomcat. We recommend atleast 4GB.
* postgresql - Refer to the [postgresql cookbook](https://github.com/hw-cookbooks/postgresql) for details.

Recipes
=======
* `default.rb` - Downloads biodiv source, compiles the source to a war file and deploys it to tomcat. Also installs utility packages like imagemagik, ntp, jpegoptim etc. 

Usage
==============

You can install biodiv on tomcat and nginx as follows.

Create a file biodiv.json with the following contents. Change the parameters to fit your setup. E.g. The biodiv servername should be your host's FQDN.  

    {
        "run_list": [
            "recipe[biodiv]"
        ],
        "biodiv": {
            "servername": "portal.wikwio.org",
            "database": "biodiv",
            "database-user": "biodiv",
            "database-password": "biodiv123",
            "data": "/apps/biodiv",
            "augmentedmaps": "/apps/biodiv",
            "version": "wikwio"
        },
        "postgresql": {
            "password": {
                "postgres": "postgres123"
            }
        },
        "tomcat": {
            "base_version": "7",
            "catalina_options": "-Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true -Dbiodiv.config.location=/usr/local/src/biodiv-master/additional-config.groovy -Xmx4g -XX:PermSize=256M -XX:MaxPermSize=512M -DBIODIV_CONFIG_LOCATION=/usr/share/tomcat7/.grails/biodiv-additional-config.groovy  -Dlog4jdbc.spylogdelegator.name=net.sf.log4jdbc.log.slf4j.Slf4jSpyLogDelegator -Dfile.encoding=UTF-8"
        },
        "java": {
            "jdk_version": "7"
        },
        "nginx": {
            "client_max_body_size": "100m",
            "user": "tomcat7",
            "group": "tomcat7"
        },
        "geoserver": {
            "database": "ibp",
            "database-user": "geoserver",
            "database-password": "geoserver123",
            "data": "/apps/biodiv/data/geoserver"
        },
        "grails": {
            "version": "2.3.9"
        },
        "postfix": {
            "main": {
                "myhostname": "wikwio.org",
                "smtp_use_tls": "no",
                "smtpd_use_tls": "no"
            }
        },
        "solr": {
            "data": "/apps/biodiv/data/solr"
        }
    }

Note: nginx and tomcat should run as the same user because the share static content files.
    
License and Author
==================

- Author:: Ashish Shinde (<ashish@strandls.com>)
- Author:: Sandeep Tadekar (<sandeept@strandls.com>)
- Author:: Prabhakar Rajagopal (<prabha@strandls.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
