const ROOT_SELECTOR = "[data-dynamic-slot-list]";

const parseJson = (value) => {
  try {
    const data = JSON.parse(value || "[]");
    return Array.isArray(data) ? data : [];
  } catch (_error) {
    return [];
  }
};

const listEl = (root) => root.querySelector("[data-dynamic-slot-list-list]");

const usedSlots = (root) =>
  Array.from((listEl(root) || document.createElement("div")).querySelectorAll("[data-dynamic-slot-list-row]")).map(
    (row) => Number(row.dataset.slot)
  );

const nextSlot = (root) => {
  const slotCount = Number(root.dataset.slotCount) || 6;
  const taken = new Set(usedSlots(root));
  for (let slot = 1; slot <= slotCount; slot += 1) {
    if (!taken.has(slot)) {
      return slot;
    }
  }
  return null;
};

const fieldsFor = (root, slot) =>
  root.querySelector(`[data-dynamic-slot-list-fields="${slot}"]`);

const uploadFor = (root, slot) =>
  root.querySelector(`[data-dynamic-slot-list-upload="${slot}"]`);

const renumberLabels = (root) => {
  const rows = Array.from((listEl(root) || document.createElement("div")).querySelectorAll("[data-dynamic-slot-list-row]"));
  rows.forEach((row, index) => {
    const label = row.querySelector("[data-dynamic-slot-list-slot-label]");
    if (label) {
      label.textContent = String(index + 1);
    }
  });
};

const updateEmptyMax = (root) => {
  const rows = usedSlots(root);
  const emptyEl = root.querySelector("[data-dynamic-slot-list-empty]");
  const maxEl = root.querySelector("[data-dynamic-slot-list-max]");
  if (emptyEl) {
    emptyEl.hidden = rows.length > 0;
  }
  if (maxEl) {
    maxEl.hidden = nextSlot(root) !== null;
  }
};

const updateAddButton = (root) => {
  const addButton = root.querySelector("[data-dynamic-slot-list-add]");
  if (!addButton) {
    return;
  }
  addButton.disabled = nextSlot(root) === null;
};

const syncJson = (root) => {
  const input = root.querySelector("[data-dynamic-slot-list-json]");
  const list = listEl(root);
  if (!input || !list) {
    return;
  }

  const items = Array.from(list.querySelectorAll("[data-dynamic-slot-list-row]")).map((row) => ({
    slot: Number(row.dataset.slot)
  }));

  input.value = JSON.stringify(items);
  renumberLabels(root);
  updateEmptyMax(root);
  updateAddButton(root);
};

const moveFieldsIntoRow = (root, row, slot) => {
  const mount = row.querySelector("[data-dynamic-slot-list-fields-mount]");
  const fields = fieldsFor(root, slot);
  if (mount && fields) {
    mount.appendChild(fields);
  }

  const uploadMount = row.querySelector("[data-dynamic-slot-list-upload-mount]");
  const upload = uploadFor(root, slot);
  if (uploadMount && upload) {
    uploadMount.appendChild(upload);
    upload.hidden = false;
  }
};

const buildRow = (root, slot) => {
  const template = root.querySelector("[data-dynamic-slot-list-row-template]");
  if (!template) {
    return null;
  }

  const fragment = template.content.cloneNode(true);
  const row = fragment.querySelector("[data-dynamic-slot-list-row]");
  row.dataset.slot = String(slot);
  moveFieldsIntoRow(root, row, slot);

  row.querySelector("[data-dynamic-slot-list-remove]")?.addEventListener("click", (event) => {
    event.preventDefault();
    const pool = root.querySelector("[data-dynamic-slot-list-pool]");
    const fields = fieldsFor(root, slot);
    if (pool && fields) {
      pool.appendChild(fields);
    }
    const uploads = root.querySelector("[data-dynamic-slot-list-uploads]");
    const upload = uploadFor(root, slot);
    if (uploads && upload) {
      uploads.appendChild(upload);
      upload.hidden = true;
    }
    row.remove();
    syncJson(root);
  });

  return row;
};

const appendRow = (root, list, slot) => {
  const row = buildRow(root, slot);
  if (!list || !row) {
    return null;
  }
  list.appendChild(row);
  return row;
};

const renderFromJson = (root) => {
  const list = listEl(root);
  const input = root.querySelector("[data-dynamic-slot-list-json]");
  if (!list || !input) {
    return;
  }

  list.innerHTML = "";
  parseJson(input.value).forEach((entry) => {
    const slot = Number(entry.slot);
    if (!slot) {
      return;
    }
    appendRow(root, list, slot);
  });
  syncJson(root);
};

const bindRoot = (root) => {
  if (root.dataset.dynamicSlotListBound === "true") {
    return;
  }
  root.dataset.dynamicSlotListBound = "true";

  root.querySelector("[data-dynamic-slot-list-add]")?.addEventListener("click", (event) => {
    event.preventDefault();
    const slot = nextSlot(root);
    if (!slot) {
      return;
    }
    appendRow(root, listEl(root), slot);
    syncJson(root);
  });

  root.closest("form")?.addEventListener("submit", () => {
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
