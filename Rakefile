task :default => :server

desc 'Build site with Jekyll'
task :build do
  jekyll '--no-server'
end

desc 'Build and start server with --auto'
task :server do
  jekyll '--server --auto'
end

desc 'Build and deploy'
task :deploy => :build do
  sh 'rsync -rtzh --progress --delete _site/ omar@50.116.59.250:~/public_html/eduvoyage.com/'
end

def jekyll(opts = '')
  sh 'rm -rf _site'
  sh 'jekyll ' + opts
end
