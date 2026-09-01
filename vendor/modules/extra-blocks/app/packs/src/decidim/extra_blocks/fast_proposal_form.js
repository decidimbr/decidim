const OVERLAY_SELECTOR = "[data-extra-blocks-fast-proposal-overlay]";
const SKIP_FIELD_KEYS = new Set(["base", "reason", "accept_terms", "content_block_id", "handler_name"]);

const csrfToken = () => {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute("content") : "";
};

const clearFieldErrors = (form) => {
  form.querySelectorAll(".is-invalid-input").forEach((input) => {
    input.classList.remove("is-invalid-input");
    input.removeAttribute("aria-invalid");
  });
  form.querySelectorAll("[data-extra-blocks-fast-proposal-field-error]").forEach((el) => {
    el.remove();
  });
};

const clearErrors = (form) => {
  const callout = form.querySelector("[data-extra-blocks-fast-proposal-error]");
  const messageEl = form.querySelector("[data-extra-blocks-fast-proposal-error-message]");
  if (callout) {
    callout.hidden = true;
  }
  if (messageEl) {
    messageEl.textContent = "";
  }
  clearFieldErrors(form);
};

const messagesFor = (value) => {
  const list = Array.isArray(value) ? value : [value];
  return list.filter(Boolean).map(String);
};

const findFieldInput = (form, attr) =>
  form.querySelector(`[name="${attr}"]`) ||
  form.querySelector(`[name="authorization_handler[${attr}]"]`) ||
  form.querySelector(`[data-extra-blocks-fast-proposal-field="${attr}"]`);

const paintFieldError = (input, message) => {
  input.classList.add("is-invalid-input");
  input.setAttribute("aria-invalid", "true");
  const span = document.createElement("span");
  span.className = "form-error is-visible";
  span.setAttribute("data-extra-blocks-fast-proposal-field-error", "");
  span.textContent = message;
  input.insertAdjacentElement("afterend", span);
};

const attachFieldErrors = (form, errors) => {
  const unmapped = [];

  Object.keys(errors).forEach((attribute) => {
    if (SKIP_FIELD_KEYS.has(attribute)) {
      return;
    }
    const messages = messagesFor(errors[attribute]);
    if (!messages.length) {
      return;
    }
    const input = findFieldInput(form, attribute);
    if (input) {
      paintFieldError(input, messages.join(" "));
    } else {
      unmapped.push(...messages);
    }
  });

  return unmapped;
};

const showErrors = (form, payload) => {
  const callout = form.querySelector("[data-extra-blocks-fast-proposal-error]");
  const messageEl = form.querySelector("[data-extra-blocks-fast-proposal-error-message]");
  if (!callout || !messageEl) {
    return;
  }

  const errors = payload.errors || {};
  const calloutMessages = [...messagesFor(errors.base), ...attachFieldErrors(form, errors)];

  if (!calloutMessages.length && payload.error) {
    calloutMessages.push(String(payload.error));
  }

  if (!calloutMessages.length) {
    return;
  }

  messageEl.textContent = calloutMessages.join(" ");
  callout.hidden = false;
};

const showOverlay = (form, redirectUrl) => {
  const root = form.closest("section") || form.parentElement;
  const overlay = root.querySelector(OVERLAY_SELECTOR);
  if (!overlay) {
    window.location.href = redirectUrl;
    return;
  }

  const message = form.dataset.extraBlocksFastProposalFormSuccessMessageValue || "";
  const buttonLabel = form.dataset.extraBlocksFastProposalFormSuccessButtonLabelValue || "";
  const seconds = Number(form.dataset.extraBlocksFastProposalFormSuccessTimeValue || "15");

  const messageEl = overlay.querySelector("[data-extra-blocks-fast-proposal-overlay-message]");
  const buttonEl = overlay.querySelector("[data-extra-blocks-fast-proposal-overlay-button]");
  if (messageEl) {
    messageEl.textContent = message;
  }
  if (buttonEl) {
    buttonEl.setAttribute("href", redirectUrl);
    if (buttonLabel) {
      buttonEl.textContent = buttonLabel;
    }
  }

  overlay.hidden = false;

  const timer = window.setTimeout(() => {
    window.location.href = redirectUrl;
  }, Math.max(seconds, 1) * 1000);

  if (buttonEl) {
    buttonEl.addEventListener(
      "click",
      (event) => {
        event.preventDefault();
        window.clearTimeout(timer);
        window.location.href = redirectUrl;
      },
      { once: true }
    );
  }
};

const bindForm = (form) => {
  if (form.dataset.extraBlocksFastProposalBound === "true") {
    return;
  }
  form.dataset.extraBlocksFastProposalBound = "true";

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    event.stopImmediatePropagation();
    if (form.dataset.extraBlocksFastProposalSubmitting === "true") {
      return;
    }
    form.dataset.extraBlocksFastProposalSubmitting = "true";
    clearErrors(form);

    const submitButton = form.querySelector('button[type="submit"]');
    if (submitButton) {
      submitButton.disabled = true;
    }

    try {
      const response = await fetch(form.dataset.extraBlocksFastProposalFormUrlValue, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": csrfToken(),
          "X-Requested-With": "XMLHttpRequest"
        },
        body: new FormData(form),
        credentials: "same-origin"
      });

      const payload = await response.json().catch(() => ({}));
      if (!response.ok) {
        form.dataset.extraBlocksFastProposalSubmitting = "false";
        showErrors(form, payload);
        if (submitButton) {
          submitButton.disabled = false;
        }
        return;
      }

      form.reset();
      if (submitButton) {
        submitButton.disabled = true;
      }
      showOverlay(form, payload.redirect_url || form.dataset.extraBlocksFastProposalFormRedirectUrlValue);
    } catch (error) {
      form.dataset.extraBlocksFastProposalSubmitting = "false";
      showErrors(form, { error: error.message || "Error" });
      if (submitButton) {
        submitButton.disabled = false;
      }
    }
  });
};

const boot = () => {
  document.querySelectorAll("form.extra-blocks-fast-proposal-form").forEach(bindForm);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

document.addEventListener("turbo:load", boot);
document.addEventListener("turbolinks:load", boot);
