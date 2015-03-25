require "rake_refactor/version"

module RakeRefactor
end

require 'rake_refactor/railtie' if defined?(Rails)