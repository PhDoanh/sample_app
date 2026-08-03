import { I18n } from "i18n-js"

const i18n = new I18n()

function currentLocale() {
  return document.body.dataset.locale || "en"
}

async function loadTranslations() {
  const locale = currentLocale()
  const response = await fetch(`/locales/${locale}.json`)
  if (response.ok) {
    i18n.store(await response.json())
    i18n.locale = locale
  }
}

document.addEventListener("turbo:load", loadTranslations)

export default i18n
