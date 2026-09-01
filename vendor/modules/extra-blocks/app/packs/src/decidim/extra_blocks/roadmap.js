const SELECTOR = "[data-extra-blocks-roadmap]";
const EVENTS_SELECTOR = ".extra-blocks-roadmap__events";
const HIGHLIGHTED_SELECTOR = ".extra-blocks-roadmap__event--highlighted";

const scrollToHighlighted = (root) => {
  const events = root.querySelector(EVENTS_SELECTOR) || root;
  if (events.scrollWidth <= events.clientWidth) {
    return;
  }

  const highlighted = events.querySelector(HIGHLIGHTED_SELECTOR);
  if (!highlighted) {
    return;
  }

  highlighted.scrollIntoView({ inline: "start", block: "nearest" });
};

const bindRoadmap = (root) => {
  if (root.dataset.extraBlocksRoadmapBound === "true") {
    return;
  }

  root.dataset.extraBlocksRoadmapBound = "true";

  // Wait for layout so overflow width is reliable on mobile.
  requestAnimationFrame(() => scrollToHighlighted(root));
};

const boot = () => {
  document.querySelectorAll(SELECTOR).forEach(bindRoadmap);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

document.addEventListener("turbo:load", boot);
document.addEventListener("turbolinks:load", boot);
