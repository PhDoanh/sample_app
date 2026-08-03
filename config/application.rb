require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RailsTutorial
  class Application < Rails::Application
    config.load_defaults 7.0

    config.i18n.default_locale = Settings.default_locale
    config.i18n.available_locales = Settings.available_locales.map(&:to_sym)
    config.i18n.fallbacks = [I18n.default_locale]

    config.active_storage.variant_processor = :mini_magick
  end
end
