$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pdf_writing_tools/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pdf_writing_tools"
  s.version     = PdfWritingTools::VERSION
  s.authors     = ["JSalvo1978"]
  s.email       = ["gianmario.salvetti@gmail.com"]
  s.summary     = "Plugin for pdf writing"
  s.description = "Plugin for pdf writing"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.13"

  s.add_development_dependency "sqlite3"
end
