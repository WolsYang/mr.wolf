Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redistogo:4d791ccf54436ffa23cb1aa261630324@dory.redistogo.com:10102/' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redistogo:4d791ccf54436ffa23cb1aa261630324@dory.redistogo.com:10102/' }
end