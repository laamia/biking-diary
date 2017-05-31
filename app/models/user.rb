class User < ActiveRecord::Base
  has_many :rides
  has_many :feelings, through: :rides
  has_secure_password

  def self.find_by_slug(slug)
    unslug = slug.split("-").join(" ")
    self.find_by('lower(username) = ?', unslug.downcase)
  end

  def slug
    self.username.downcase.split(" ").join("-")
  end

  def authenticate(password)
    if self.password == password
      self
    else
      false
    end
  end
end
