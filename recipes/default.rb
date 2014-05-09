
# put values directly in here for testing purposes for now, move to attributes once a working solution

maven_repos               = node['alfresco']['maven']['repos']
root_dir                  = node['alfresco']['root_dir']

cache_path                = Chef::Config['file_cache_path']

mmt_repo_workingpath     = "#{cache_path}/amp_repo/"
# mmt_binpath				= "#{cache_path}/amp_bin/"
mmt_binpath				= "/tmp/amp_bin/"

mmt_groupId             = 'org.alfresco'
mmt_artifactId          = 'alfresco-mmt'
mmt_version             = '4.2.f'

#truezip_groupId      ='de.schlichtherle.truezip'
#truezip_artifactId   ='truezip'
#truezip_version       ='5.1.2'

truezip_groupId      ='de.schlichtherle.truezip'
truezip_version       ='7.7.6'

truezipfile_artifactId   ='truezip-file'
truezipdriverfile_artifactId   ='truezip-driver-file'
truezipkernel_artifactId   ='truezip-kernel'
truezipswing_artifactId   ='truezip-swing'

    
	
webapp_dir                = node['tomcat']['webapp_dir']
tomcat_dir                = node['tomcat']['home']
tomcat_base_dir           = node['tomcat']['base']
tomcat_user               = node['tomcat']['user']
tomcat_group              = node['tomcat']['group']



directory "mmt_repo_workingpath" do
  path        mmt_repo_workingpath
  owner       tomcat_user
  group       tomcat_group
  mode        "0775"
  recursive   true
  action :create
end

directory "mmt_binpath" do
  path        mmt_binpath 
  owner       tomcat_user
  group       tomcat_group
  mode        "0775"
  recursive   true
  action :create
end

#if !mmt_binpath.nil?
# download mmt_jar only if not there. Note the maven "<name>" plus .jar is the filename.
  maven "alfresco-mmt" do
    artifact_id   mmt_artifactId
    group_id      mmt_groupId
    version       mmt_version
    action        :put
    dest          mmt_binpath
    owner         tomcat_user
    packaging     'jar'
    repositories  maven_repos
	subscribes          :put, "mmt_binpath", :immediately
  end
#end

# de/schlichtherle/truzip/file/TFile
# apparently only one version regardless of alfresco-mmt version...good...
  maven "truezipfile" do
    artifact_id   truezipfile_artifactId
    group_id      truezip_groupId
    version       truezip_version
    action        :put
    dest          mmt_binpath
    owner         tomcat_user
    packaging     'jar'
    repositories  maven_repos
	subscribes          :put, "mmt_binpath", :immediately
  end

  maven "truezipdriverfile" do
    artifact_id   truezipdriverfile_artifactId
    group_id      truezip_groupId
    version       truezip_version
    action        :put
    dest          mmt_binpath
    owner         tomcat_user
    packaging     'jar'
    repositories  maven_repos
	subscribes          :put, "mmt_binpath", :immediately
  end

  maven "truezipkernel" do
    artifact_id   truezipkernel_artifactId
    group_id      truezip_groupId
    version       truezip_version
    action        :put
    dest          mmt_binpath
    owner         tomcat_user
    packaging     'jar'
    repositories  maven_repos
	subscribes          :put, "mmt_binpath", :immediately
  end

  maven "truezipswing" do
    artifact_id   truezipswing_artifactId
    group_id      truezip_groupId
    version       truezip_version
    action        :put
    dest          mmt_binpath
    owner         tomcat_user
    packaging     'jar'
    repositories  maven_repos
	subscribes          :put, "mmt_binpath", :immediately
  end



### Download remote file
remote_file "#{mmt_repo_workingpath}/amp-mediapreview.amp" do
  source node['amp-mediapreview']['2.6.0']['url']
  owner 'tomcat_user'
  group 'tomcat_group'
 end
 

###  Install AMP
execute "Install AMPs into WARs" do
  user 'tomcat_user'
  group 'tomcat_group'
  command <<-COMMAND.gsub(/^ {2}/, '')

#  java -jar #{mmt_binpath}/alfresco-mmt.jar -cp #{mmt_binpath}truezip.jar install #{mmt_repo_workingpath} #{webapp_dir}/alfresco.war -force -directory -verbose
  java -jar #{mmt_binpath}/alfresco-mmt.jar -cp #{mmt_binpath}truezipfile.jar;#{mmt_binpath}truezipdriverfile.jar;#{mmt_binpath}truezipkernel.jar;#{mmt_binpath}truezipswing.jar install #{mmt_repo_workingpath} #{webapp_dir}/alfresco.war -force -directory -verbose


#  && \\ 
#  java -jar #{mmt_binpath}/alfresco-mmt.jar list #{webapp_dir}/alfresco.war
  COMMAND
#  subscribes :run, "maven[mmt_jar]", :immediately  
end


# 4.2.d, alfresco-mmt install and list
# NoClassDefFoundError: de/schlichtherle/truezip/socket/IOPoolProvider
# 4.2.d, alfresco-mmt install only
# NoClassDefFoundError: de/schlichtherle/truzip/file/TFile
# 4.2.f, alfresco-mmt install only
# NoClassDefFoundError: de/schlichtherle/truzip/file/TFile

### stop tomcat service somehow....
service "tomcat"  do
  action      :stop
#  subscribes  :restart, "ruby-block[deploy-share-warpath]",:immediately
#  subscribes  :restart, "ruby-block[deploy-share]",:immediately
end




###  Install AMP
# execute "Install AMPs into WARs" do
#  user alfresco_user
#  group alfresco_group
#  command <<-COMMAND.gsub(/^ {2}/, '')

#  java -jar #{tomcat_dir}/bin/alfresco-mmt.jar install #{tomcat_dir}/amps #{temp_dir}/alfresco.war -directory -verbose && \\
#  java -jar #{tomcat_dir}/bin/alfresco-mmt.jar list #{temp_dir}/alfresco.war && \\
#  java -jar #{tomcat_dir}/bin/alfresco-mmt.jar install #{tomcat_dir}/amps_share #{temp_dir}/share.war -directory -verbose && \\
#  java -jar #{tomcat_dir}/bin/alfresco-mmt.jar list #{temp_dir}/share.war
#  COMMAND
#end
