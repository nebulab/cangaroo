namespace :cangaroo do
  task poll: :environment do
    Cangaroo::RunPolls.call(
      jobs: Rails.configuration.cangaroo.poll_jobs
    )
  end
end
