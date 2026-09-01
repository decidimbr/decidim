const SELECTOR = "[data-extra-blocks-media-aside-slideshow]";
const SLIDE_SELECTOR = "[data-extra-blocks-media-aside-slide]";
const DEFAULT_INTERVAL_MS = 5000;

const prefersReducedMotion = () =>
  window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

const bindSlideshow = (root) => {
  if (root.dataset.extraBlocksMediaAsideSlideshowBound === "true") {
    return;
  }

  const slides = Array.from(root.querySelectorAll(SLIDE_SELECTOR));
  if (slides.length < 2 || prefersReducedMotion()) {
    return;
  }

  root.dataset.extraBlocksMediaAsideSlideshowBound = "true";

  let index = slides.findIndex((slide) => slide.classList.contains("is-active"));
  if (index < 0) {
    index = 0;
    slides[0].classList.add("is-active");
  }

  const intervalMs = Number(root.dataset.interval) || DEFAULT_INTERVAL_MS;

  window.setInterval(() => {
    slides[index].classList.remove("is-active");
    index = (index + 1) % slides.length;
    slides[index].classList.add("is-active");
  }, Math.max(intervalMs, 1000));
};

const boot = () => {
  document.querySelectorAll(SELECTOR).forEach(bindSlideshow);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

document.addEventListener("turbo:load", boot);
document.addEventListener("turbolinks:load", boot);
