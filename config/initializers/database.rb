Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    config = Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = (ENV['DB_REAP_FREQ'] || 5).to_i # seconds
    config['pool']              = (ENV['DB_POOL']      || 100).to_i
    ActiveRecord::Base.establish_connection(config)
  end
end
