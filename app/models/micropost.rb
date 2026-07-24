class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates(
    :content,
    presence: true,
    length: {maximum: Settings.micropost.content.max_length}
  )

  validates(
    :image,
    content_type: {in: Settings.micropost.image.content_type},
    size: {less_than: Settings.micropost.image.max_size.megabytes}
  )

  scope :recent, ->{order(created_at: :desc)}
  scope :feed, ->(user){where(user_id: user.following_ids << user.id)}
end
