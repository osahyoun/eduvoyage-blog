#
# Jekyll Generator for SCSS
#
# (File paths in this description relative to jekyll project root directory)
# Place this file in ./_plugins
# Place .scss files in ./_scss
# Compiles .scss files in ./_scss to .css files in whatever directory you indicated in your config
# Config file placed in ./_sass/config.rb
#

require 'sass'
require 'pathname'
require 'compass'
require 'compass/exec'

module Jekyll

  class CompassGenerator < Generator
    safe true
    
    def generate(site)
      # Compass::Exec::SubCommandUI.new(["compile", "--sass-dir", '_scss', '--css-dir', 'stylesheets']).run!
    end
    
  end
  
end