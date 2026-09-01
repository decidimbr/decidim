const ROOT_SELECTOR = "[data-dynamic-events]";

const parseJson = (value) => {
  try {
    const data = JSON.parse(value || "[]");
    return Array.isArray(data) ? data : [];
  } catch (_error) {
    return [];
  }
};

const usedSlots = (list) =>
  Array.from(list.querySelectorAll("[data-dynamic-events-row]")).map((row) =>
    Number(row.dataset.slot)
  );

const nextSlot = (root) => {
  const slotCount = Number(root.dataset.slotCount) || 5;
  const taken = new Set(usedSlots(root.querySelector("[data-dynamic-events-list]")));
  for (let slot = 1; slot <= slotCount; slot += 1) {
    if (!taken.has(slot)) {
      return slot;
    }
  }
  return null;
};

const fieldsFor = (root, slot) =>
  root.querySelector(`[data-dynamic-events-fields="${slot}"]`);

const syncJson = (root) => {
  const input = root.querySelector("[data-dynamic-events-json]");
  const list = root.querySelector("[data-dynamic-events-list]");
  if (!input || !list) {
    return;
  }

  const items = Array.from(list.querySelectorAll("[data-dynamic-events-row]")).map((row) => ({
    slot: Number(row.dataset.slot),
    highlighted: Boolean(row.querySelector("[data-dynamic-events-highlighted]")?.checked)
  }));

  input.value = JSON.stringify(items);
  renumberLabels(root);
  updateEmptyMax(root);
  updateAddButton(root);
};

const renumberLabels = (root) => {
  const rows = Array.from(
    (root.querySelector("[data-dynamic-events-list]") || document.createElement("div")).querySelectorAll(
      "[data-dynamic-events-row]"
    )
  );
  rows.forEach((row, index) => {
    const label = row.querySelector("[data-dynamic-events-slot-label]");
    if (label) {
      label.textContent = String(index + 1);
    }
  });
};

const updateEmptyMax = (root) => {
  const count = usedSlots(root.querySelector("[data-dynamic-events-list]") || document.createElement("div")).length;
  const emptyEl = root.querySelector("[data-dynamic-events-empty]");
  const maxEl = root.querySelector("[data-dynamic-events-max]");
  if (emptyEl) {
    emptyEl.hidden = count > 0;
  }
  if (maxEl) {
    maxEl.hidden = nextSlot(root) !== null;
  }
};

const updateAddButton = (root) => {
  const addButton = root.querySelector("[data-dynamic-events-add]");
  if (!addButton) {
    return;
  }
  addButton.disabled = nextSlot(root) === null;
};

const moveFieldsIntoRow = (root, row, slot) => {
  const mount = row.querySelector("[data-dynamic-events-fields-mount]");
  const fields = fieldsFor(root, slot);
  if (!mount || !fields) {
    return;
  }
  mount.appendChild(fields);
};

const buildRow = (root, slot, highlighted = false) => {
  const template = root.querySelector("[data-dynamic-events-row-template]");
  if (!template) {
    return null;
  }

  const fragment = template.content.cloneNode(true);
  const row = fragment.querySelector("[data-dynamic-events-row]");
  row.dataset.slot = String(slot);
  moveFieldsIntoRow(root, row, slot);

  const highlightedInput = row.querySelector("[data-dynamic-events-highlighted]");
  if (highlightedInput) {
    highlightedInput.checked = Boolean(highlighted);
    highlightedInput.addEventListener("change", () => syncJson(root));
  }

  row.querySelector("[data-dynamic-events-remove]").addEventListener("click", (event) => {
    event.preventDefault();
    const pool = root.querySelector("[data-dynamic-events-pool]");
    const fields = fieldsFor(root, slot);
    if (pool && fields) {
      pool.appendChild(fields);
    }
    row.remove();
    syncJson(root);
  });

  return row;
};

const appendRow = (root, list, slot, highlighted = false) => {
  const row = buildRow(root, slot, highlighted);
  if (!list || !row) {
    return null;
  }

  list.appendChild(row);
  return row;
};

const renderFromJson = (root) => {
  const list = root.querySelector("[data-dynamic-events-list]");
  const input = root.querySelector("[data-dynamic-events-json]");
  if (!list || !input) {
    return;
  }

  list.innerHTML = "";
  parseJson(input.value).forEach((entry) => {
    const slot = Number(entry.slot);
    if (!slot) {
      return;
    }
    appendRow(root, list, slot, entry.highlighted);
  });
  syncJson(root);
};

const bindRoot = (root) => {
  if (root.dataset.dynamicEventsBound === "true") {
    return;
  }
  root.dataset.dynamicEventsBound = "true";

  root.querySelector("[data-dynamic-events-add]")?.addEventListener("click", (event) => {
    event.preventDefault();
    const slot = nextSlot(root);
    if (!slot) {
      return;
    }
    const list = root.querySelector("[data-dynamic-events-list]");
    appendRow(root, list, slot);
    syncJson(root);
  });

  const form = root.closest("form");
  form?.addEventListener("submit", () => {
    syncJson(root);
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
