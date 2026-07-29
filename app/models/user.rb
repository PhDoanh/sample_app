class User < ApplicationRecord
  before_save{email.downcase!}

  VALID_EMAIL_REGEX = Settings.regex.email

  validates :name, presence: true, length:
    {maximum: Settings.user.name.max_length}

  validates(
    :email,
    presence: true,
    format: {with: VALID_EMAIL_REGEX},
    length: {maximum: Settings.user.email.max_length},
    uniqueness: true
  )

  has_secure_password
  validates :password, presence: true, length:
    {minimum: Settings.user.password.min_length}

  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end

    BCrypt::Password.create(string, cost:)
  end
end
