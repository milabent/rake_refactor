module RakeRefactor
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/refactor.rake"
    end
  end
end