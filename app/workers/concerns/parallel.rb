module Parallel
  extend ActiveSupport::Concern

  # def reconnect_database
  #   ActiveRecord::Base.connection.reconnect!
  # rescue PG::Error => e
  #   warn "Failed to connect, will try again in a second"
  #   warn e
  #   sleep(1)
  #   retry
  # end

  # def mapp(array, processes = 8, &block)
  #   Parallel.map(array, :in_processes => processes) do |el|
  #     ActiveRecord::Base.connection.reconnect!
  #     block.call(el)
  #   end
  # end

  module ClassMethods

    def mapp(array, processes = 8, &block)
      Parallel.map(array, :in_processes => processes) do |el|
        ActiveRecord::Base.connection.reconnect!
        block.call(el)
      end
    end

  end

end
