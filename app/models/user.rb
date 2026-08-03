class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many(
    :active_relationships,
    class_name: "Relationship",
    foreign_key: "follower_id",
    dependent: :destroy
  )
  has_many :following, through: :active_relationships, source: :followed

  has_many(
    :passive_relationships,
    class_name: "Relationship",
    foreign_key: "followed_id",
    dependent: :destroy
  )
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :reset_token, :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest

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
  validates(
    :password,
    presence: true,
    length: {minimum: Settings.user.password.min_length},
    allow_nil: true
  )

  scope :newest, ->{order(created_at: :desc).where(activated: true)}

  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end

    BCrypt::Password.create(string, cost:)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def session_token
    remember_digest || remember
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.user.password_reset_expire_time.hours.ago
  end

  # Eager loading approach (fix N+1 query problem)
  def feed
    Micropost
      .feed(self)
      .recent
      .includes(:user, image_attachment: :blob)
  end

  def follow other_user
    following << other_user unless self == other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  def active_relationship_with other_user
    active_relationships.find_by(followed: other_user)
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
