class MkTest
  include Sidekiq::Worker

  def perform(query)
  end
end
