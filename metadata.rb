name			 "amp-mediapreview"
maintainer       "Darren Hartford"
maintainer_email "binarymonk01@gmail.com"
license          "Apache 2.0"
description      "Installs Alfresco AMP Media Preview"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

# http://share-extras.github.io/addons/media-viewers/

# alfresco repository and share WAR's should already be installed.
# include_recipe "alfresco"


recipe "amp-mediaviewer",                  "Installs AMP file."

%w{ ubuntu centos redhat fedora }.each do |os|
  supports os
end

%w{ ark tomcat alfresco }.each do |cb|
  depends cb
end
