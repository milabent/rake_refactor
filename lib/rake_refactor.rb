require "rake_refactor/version"

module RakeRefactor
  require 'rake_refactor/railtie' if defined?(Rails)
end
