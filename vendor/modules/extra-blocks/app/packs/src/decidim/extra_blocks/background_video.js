/* ponytail: autoplay-then-pause still flashes one frame; omit autoplay, play() only if !prefers-reduced-motion */
const SELECTOR = ".extra-blocks-video-hero__video, .extra-blocks-video-fast-proposal__video";

const prefersReducedMotion = () =>
  window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

const playBackgroundVideo = (video) => {
  if (prefersReducedMotion()) {
    return;
  }

  const play = video.play();
  if (play && typeof play.catch === "function") {
    play.catch(() => {});
  }
};

const boot = () => {
  document.querySelectorAll(SELECTOR).forEach(playBackgroundVideo);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

document.addEventListener("turbo:load", boot);
document.addEventListener("turbolinks:load", boot);
