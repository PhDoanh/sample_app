module UsersHelper
  # Returns the Gravatar for the given user.
  def gravatar_for user, size: Settings.user.gravatar.medium_size
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = format(Settings.url.gravatar_template, gravatar_id:, size:)
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
