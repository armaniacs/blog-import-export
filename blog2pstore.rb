#!/usr/bin/env ruby -Ku
#
# blog2pstore.rb: This script backups your Blog to your localhost. 
#
# You can backup
# - All articles
# - All categories 
#
# Before using this, please fill in your resources.
##### user setting

username = "username"
password = "password"
dbfile = "/tmp/blog-get"
endhost = "endpoint.example.com"
endpath = "/api/xmlrpc.cgi"

#####


require "xmlrpc/client"
require "pstore"
db = PStore.new(dbfile)
proxy = XMLRPC::Client.new(endhost,endpath)

categories = proxy.call("metaWeblog.getCategories", "", username, password)
db.transaction do
  db["categories"] = categories
end

r = proxy.call("metaWeblog.getRecentPosts", "", username,password, 1)
maxnumber = r.first["postid"] 

articles = Hash.new
i = 1

while i <= maxnumber.to_i do 
  begin
    articles[i] = proxy.call("metaWeblog.getPost", i, username,password)
  rescue
    sleep 1
  end
  sleep 1 if i.modulo(10) == 0
  i +=1
end

db.transaction do
  db["articles"] = articles
end

