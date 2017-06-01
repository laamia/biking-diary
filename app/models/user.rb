class User < ActiveRecord::Base
  has_many :rides
  has_many :feelings, through: :rides
  has_secure_password

  def total_miles
    total_miles = 0
    self.rides.each do |ride|
      total_miles += ride.miles
    end
    total_miles
  end
end
