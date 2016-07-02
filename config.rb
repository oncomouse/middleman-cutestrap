###
# Compass
###
set :markdown_engine, :kramdown
set :markdown, :fenced_code_blocks => true,
			   :autolink => true, 
			   :smartypants => true,
			   :footnotes => true,
			   :superscript => true

set :haml, { :ugly => false, :format => :html5 }

npm_prefix = `npm bin`.strip

activate :bem_html
config[:classes_to_keep] = [
	'no-js'
]
config[:internal_css] = false

if not build?
	activate :external_pipeline,
		name: :gulp,
		command: "#{npm_prefix}/gulp watch",
		source: ".tmp/dist",
		latency: 2
end
after_build do
	activate :external_pipeline,
		name: :gulp,
		command: "env NODE_ENV=production #{npm_prefix}/gulp build",
		source: ".tmp/dist",
		latency: 2
end

aliases = [
	#{
	#	to: "/fonts/roboto/",
	#	from: "/bower_components/Materialize/fonts/roboto/"
	#}
]

if not build?
	after_configuration do 
		import_path File.expand_path('bower_components', app.root)

		require "rack/rewrite"

		use ::Rack::Rewrite do
			aliases.each do |al|
				file_path = File.join(Dir.pwd, al[:from])
				if File.directory? file_path
					rewrite %r{^#{al[:to].sub(/\/$/,"")}\/(.*)}, al[:from].sub(/\/$/,"") + '/$1'
				else
					rewrite %r{^#{al[:to]}}, al[:from]
				end
			end
		end
	end
end

require 'fileutils'
after_build do
	aliases.each do |al|
		file_path = File.join(Dir.pwd, al[:from])
		printf "\033[1m\033[32m%12s\033[0m  %s\n", "copying", "#{al[:from]}"
		FileUtils.mkdir_p File.join(Dir.pwd, config[:build_dir], al[:to])
		system("cp -r \"#{file_path.sub(/\/$/,"")}/\"* #{File.join(Dir.pwd, config[:build_dir], al[:to])}")
	end	
end

###
# Helpers
###


set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

## Build-specific configuration
configure :build do

    # Don't edit these lines:
	ignore "node_modules/*"
	ignore 'bower_components/*'
	ignore "javascripts/*"
	ignore "stylesheets/*"
	
	# Change this to build with a different file root.
	set :http_prefix, "/"

	activate :cache_buster
end

activate :deploy do |deploy|
	deploy.deploy_method = :rsync
	deploy.user = "you"
	deploy.host = "you.your-server.com"
	deploy.path = "~/www/wherever/whenever"
end