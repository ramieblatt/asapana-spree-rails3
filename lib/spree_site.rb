module SpreeSite
  class Engine < Rails::Engine
    def self.activate
      # Add your custom site logic here
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    
    def load_tasks
    end
    
    config.to_prepare &method(:activate).to_proc
  end
end