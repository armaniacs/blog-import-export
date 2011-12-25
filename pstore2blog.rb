#!/usr/bin/env ruby -Ku
#
# pstore2blog.rb: This script imports your backup Blog to your new blog.
#
# You can imports
# - All articles
# - All categories 
#
# Before using this, please fill in your resources.
##### user setting

username = "username"
password = "password"
dbfile = "/tmp/blog-get"
faildbfile = "/tmp/blog-fail"

endurl = "endpoint.example.com"
# endurl = "http://XXX.wordpress.com/xmlrpc.php"

#####


require "pstore"
require "xmlrpc/client"
db = PStore.new(dbfile)
faildb = PStore.new(faildbfile)

articles = Hash.new
fails = Hash.new
categories = Hash.new

db.transaction do
  articles = db["articles"]
  categories = db["categories"]
end

proxy = XMLRPC::Client.new_from_uri(endurl)

categories.each do |c|
  proxy.call("wp.newCategory", "", username,password,
             {'name' => c['description']}
             )
end

articles.each do |k,a|
  begin
    postid = proxy.call("metaWeblog.newPost", "", username,password,
                          {
                            'title' => a['title'],
                            'categories' => a['categories'],
                            'description' => a['description'],
                            'dateCreated' => a['dateCreated'],
                          },1
                          )
  rescue
    fails.store(k,a)
  end
end

faildb.transaction do
  faildb = fails
end

