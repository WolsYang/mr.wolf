class JobCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JobCleanupJob
  end
end
