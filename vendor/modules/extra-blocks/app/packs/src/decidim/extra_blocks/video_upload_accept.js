const ACCEPT_BY_NAME = {
  background_video_webm: ".webm,video/webm,audio/webm",
  background_video: ".mp4,video/mp4,application/mp4"
};

const applyAccept = (dropzone) => {
  const accept = ACCEPT_BY_NAME[dropzone.dataset.name];
  const input = dropzone.querySelector("input[type=file]");
  if (!accept || !input) {
    return;
  }

  input.setAttribute("accept", accept);
};

const boot = () => {
  document.querySelectorAll("[data-dropzone][data-name]").forEach(applyAccept);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

document.addEventListener("turbo:load", boot);
document.addEventListener("turbolinks:load", boot);
