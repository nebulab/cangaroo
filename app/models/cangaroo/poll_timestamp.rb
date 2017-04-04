module Cangaroo
  class PollTimestamp < ActiveRecord::Base
    serialize :value

    belongs_to :connection

    validates_uniqueness_of :job, scope: :connection

    def self.for_class(klass)
      where(
        job: klass.to_s,
        connection: Cangaroo::Connection.find_by!(name: klass.connection)
      ).first_or_initialize
    end
  end
end
