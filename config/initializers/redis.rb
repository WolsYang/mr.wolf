uri = URI.parse(ENV["redis://redistogo:4d791ccf54436ffa23cb1aa261630324@dory.redistogo.com:10102/"])
REDIS = Redis.new(:url => uri)