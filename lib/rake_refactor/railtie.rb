module RakeRefactor
  class Railtie < Rails::Railtie
    rake_tasks do
      load "lib/tasks/refactor.rake"
    end
  end
end