import i18n from "i18n";

document.addEventListener("turbo:load", function() {
  document.addEventListener("change", function(event) {
    let image_upload = document.querySelector('#micropost_image');
    const size_in_megabytes = image_upload.files[0].size/1024/1024;
    if (size_in_megabytes > gon.global.maxImageSize) {
      alert(i18n.t("js.micropost.image_too_large"));
      image_upload.value = "";
    }
  });
});
