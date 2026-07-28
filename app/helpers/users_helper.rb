module UsersHelper
  # Returns the Gravatar for the given user.
  def gravatar_for user, size: Settings.user.gravatar.size
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = Settings.url.gravatar.format(gravatar_id:, size:)
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
