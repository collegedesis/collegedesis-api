class User < ActiveRecord::Base
  attr_accessible :email, :full_name, :password, :password_confirmation
  attr_accessor :password

  validates_confirmation_of :password
  validates_presence_of :full_name
  validates_presence_of :password, on: :create
  validates_presence_of :email
  validates_uniqueness_of :email
  
  before_save :encrypt_password

  has_many :memberships

  def name
    "#{first_name} #{last_name}"
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end