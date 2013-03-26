# -*- encoding: utf-8 -*-
require 'json'

package = JSON.parse(File.read('package.json'))

Gem::Specification.new do |gem|
  gem.name          = "ember_script-source"
  gem.authors       = ["Gordon Hempton"]
  gem.email         = ["ghempton@gmail.com"]
  gem.date          = Time.now.strftime("%Y-%m-%d")
  gem.description   = %q{EmberScript source code wrapper for (pre)compilation gems.}
  gem.summary       = %q{EmberScript source code wrapper}
  gem.homepage      = "https://github.com/ghempton/ember-script/"
  gem.version       = package["version"]

  gem.files = [
    'dist/ember-script.js',
    'dist/ember-script.js.map',
    'lib/ember_script/source.rb'
  ]
end