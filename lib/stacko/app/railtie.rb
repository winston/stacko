module Stacko
  class Railtie < ::Rails::Railtie
    railtie_name :stacko

    rake_tasks do
      load "tasks/stacko.rake"
    end
  end
end
