const ROOT_SELECTOR = "[data-dynamic-logos]";
const ALT_NAME_PATTERN = /\[alt_([^\]]+)\]$/;

const parseJson = (value) => {
  try {
    const data = JSON.parse(value || "[]");
    return Array.isArray(data) ? data : [];
  } catch (_error) {
    return [];
  }
};

const usedSlots = (list) =>
  Array.from(list.querySelectorAll("[data-dynamic-logos-row]")).map((row) =>
    Number(row.dataset.slot)
  );

const nextSlot = (root) => {
  const slotCount = Number(root.dataset.slotCount) || 12;
  const taken = new Set(usedSlots(root.querySelector("[data-dynamic-logos-list]")));
  for (let slot = 1; slot <= slotCount; slot += 1) {
    if (!taken.has(slot)) {
      return slot;
    }
  }
  return null;
};

const uploadFor = (root, slot) =>
  root.querySelector(`[data-dynamic-logos-upload="${slot}"]`);

const syncUploads = (root) => {
  const slotCount = Number(root.dataset.slotCount) || 12;
  const active = new Set(usedSlots(root.querySelector("[data-dynamic-logos-list]")));
  for (let slot = 1; slot <= slotCount; slot += 1) {
    const upload = uploadFor(root, slot);
    if (!upload) {
      continue;
    }
    upload.hidden = !active.has(slot);
  }
};

const localeFromInputName = (name) => {
  const match = String(name || "").match(ALT_NAME_PATTERN);
  if (!match) {
    return null;
  }
  return match[1].replace(/__/g, "-");
};

const altInputs = (row) =>
  Array.from(row.querySelectorAll('input[type="text"][name*="[alt_"]'));

const syncJson = (root) => {
  const input = root.querySelector("[data-dynamic-logos-json]");
  const list = root.querySelector("[data-dynamic-logos-list]");
  if (!input || !list) {
    return;
  }

  const items = Array.from(list.querySelectorAll("[data-dynamic-logos-row]")).map((row) => {
    const alt = {};
    altInputs(row).forEach((field) => {
      const locale = localeFromInputName(field.name);
      const value = field.value.trim();
      if (locale && value) {
        alt[locale] = value;
      }
    });
    return { slot: Number(row.dataset.slot), alt };
  });

  input.value = JSON.stringify(items);
  syncUploads(root);
  renumberLabels(root);
  updateEmptyMax(root);
  updateAddButton(root);
};

const renumberLabels = (root) => {
  const rows = Array.from(
    (root.querySelector("[data-dynamic-logos-list]") || document.createElement("div")).querySelectorAll(
      "[data-dynamic-logos-row]"
    )
  );
  rows.forEach((row, index) => {
    const label = row.querySelector("[data-dynamic-logos-slot-label]");
    if (label) {
      label.textContent = String(index + 1);
    }
  });
};

const updateEmptyMax = (root) => {
  const count = usedSlots(root.querySelector("[data-dynamic-logos-list]") || document.createElement("div")).length;
  const emptyEl = root.querySelector("[data-dynamic-logos-empty]");
  const maxEl = root.querySelector("[data-dynamic-logos-max]");
  if (emptyEl) {
    emptyEl.hidden = count > 0;
  }
  if (maxEl) {
    maxEl.hidden = nextSlot(root) !== null;
  }
};

const updateAddButton = (root) => {
  const addButton = root.querySelector("[data-dynamic-logos-add]");
  if (!addButton) {
    return;
  }
  addButton.disabled = nextSlot(root) === null;
};

const fillAltFields = (row, alt) => {
  const values = alt && typeof alt === "object" ? alt : {};
  altInputs(row).forEach((field) => {
    const locale = localeFromInputName(field.name);
    field.value = (locale && values[locale]) || "";
  });
};

const moveUploadIntoRow = (root, row, slot) => {
  const mount = row.querySelector("[data-dynamic-logos-upload-mount]");
  const upload = uploadFor(root, slot);
  if (!mount || !upload) {
    return;
  }
  mount.appendChild(upload);
  upload.hidden = false;
};

const replaceSlotPlaceholder = (row, placeholder, slot) => {
  const from = String(placeholder || "SLOT");
  const to = String(slot);
  const attributes = ["id", "href", "name", "for", "data-tabs-content", "aria-controls"];

  row.querySelectorAll("*").forEach((el) => {
    attributes.forEach((attr) => {
      const current = el.getAttribute(attr);
      if (current && current.includes(from)) {
        el.setAttribute(attr, current.split(from).join(to));
      }
    });
  });
};

// Decidim admin pattern (dynamic_fields.component.js): set data-tabs then window.initFoundation.
const initTranslatedTabs = (row) => {
  row.querySelectorAll("ul.tabs").forEach((tabs) => {
    tabs.setAttribute("data-tabs", "true");
  });

  if (typeof window.initFoundation === "function") {
    window.initFoundation(row);
    return;
  }

  if (window.$) {
    window.$(row).foundation();
  }
};

const disableAltParamInputs = (root) => {
  root.querySelectorAll('input[name^="dynamic_logos["]').forEach((field) => {
    field.disabled = true;
  });
};

const buildRow = (root, slot, alt = {}) => {
  const template = root.querySelector("[data-dynamic-logos-row-template]");
  if (!template) {
    return null;
  }

  const fragment = template.content.cloneNode(true);
  const row = fragment.querySelector("[data-dynamic-logos-row]");
  row.dataset.slot = String(slot);
  replaceSlotPlaceholder(row, root.dataset.slotPlaceholder, slot);
  fillAltFields(row, alt);
  moveUploadIntoRow(root, row, slot);

  row.querySelector("[data-dynamic-logos-remove]").addEventListener("click", (event) => {
    event.preventDefault();
    const uploads = root.querySelector("[data-dynamic-logos-uploads]");
    const upload = uploadFor(root, slot);
    if (uploads && upload) {
      uploads.appendChild(upload);
      upload.hidden = true;
    }
    row.remove();
    syncJson(root);
  });

  altInputs(row).forEach((field) => {
    field.addEventListener("input", () => syncJson(root));
  });

  return row;
};

const appendRow = (root, list, slot, alt = {}) => {
  const row = buildRow(root, slot, alt);
  if (!list || !row) {
    return null;
  }

  list.appendChild(row);
  // Foundation tabs need the node in the document (Decidim admin dynamic_fields pattern).
  initTranslatedTabs(row);
  return row;
};

const renderFromJson = (root) => {
  const list = root.querySelector("[data-dynamic-logos-list]");
  const input = root.querySelector("[data-dynamic-logos-json]");
  if (!list || !input) {
    return;
  }

  list.innerHTML = "";
  parseJson(input.value).forEach((entry) => {
    const slot = Number(entry.slot);
    if (!slot) {
      return;
    }
    appendRow(root, list, slot, entry.alt || {});
  });
  syncJson(root);
};

const bindRoot = (root) => {
  if (root.dataset.dynamicLogosBound === "true") {
    return;
  }
  root.dataset.dynamicLogosBound = "true";

  root.querySelector("[data-dynamic-logos-add]")?.addEventListener("click", (event) => {
    event.preventDefault();
    const slot = nextSlot(root);
    if (!slot) {
      return;
    }
    const list = root.querySelector("[data-dynamic-logos-list]");
    appendRow(root, list, slot);
    syncJson(root);
  });

  const form = root.closest("form");
  form?.addEventListener("submit", () => {
    syncJson(root);
    // Keep logos_json as source of truth; do not submit per-locale dynamic_logos[*] params.
    disableAltParamInputs(root);
  });

  renderFromJson(root);
};

const boot = () => {
  document.querySelectorAll(ROOT_SELECTOR).forEach(bindRoot);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

document.addEventListener("turbo:load", boot);
document.addEventListener("turbolinks:load", boot);
