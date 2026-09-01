/**
 * ActiveStorage BlobRecord only reads csrf-token from document.head.
 * Decidim validation uses a document-wide meta query. Ensure head has a
 * non-empty global meta token before BlobRecord is constructed.
 *
 * Prefer an existing non-empty head meta. Never replace it with a per-form
 * authenticity_token (per_form_csrf_tokens may reject that for DirectUploads).
 *
 * Patch XHR open (not DirectUpload.prototype): admin Uploader lives in the
 * decidim_admin pack and may use a different webpack copy of ActiveStorage,
 * so a prototype patch on this pack's import never runs for real uploads.
 * BlobRecord order is open → getMetaValue("csrf-token") → setRequestHeader.
 */
const CSRF_META = 'meta[name="csrf-token"]';
const DIRECT_UPLOADS_PATH = "/rails/active_storage/direct_uploads";

const nonEmptyContent = (element) => {
  const content = element?.getAttribute("content");
  if (!content || !content.trim()) {
    return null;
  }

  return content;
};

const globalMetaToken = () => {
  const metas = document.querySelectorAll(CSRF_META);
  for (let i = 0; i < metas.length; i += 1) {
    const token = nonEmptyContent(metas[i]);
    if (token) {
      return token;
    }
  }

  return null;
};

export const ensureHeadCsrfMeta = () => {
  if (!document.head) {
    return;
  }

  const headMeta = document.head.querySelector(CSRF_META);
  if (nonEmptyContent(headMeta)) {
    return;
  }

  const token = globalMetaToken();
  if (!token) {
    return;
  }

  if (headMeta) {
    headMeta.setAttribute("content", token);
    return;
  }

  const meta = document.createElement("meta");
  meta.setAttribute("name", "csrf-token");
  meta.setAttribute("content", token);
  document.head.appendChild(meta);
};

const patchXhrOpen = () => {
  const { open } = XMLHttpRequest.prototype;
  if (open.__extraBlocksDirectUploadCsrf) {
    return;
  }

  function patchedOpen(method, url, ...args) {
    if (
      String(method).toUpperCase() === "POST" &&
      typeof url === "string" &&
      url.includes(DIRECT_UPLOADS_PATH)
    ) {
      ensureHeadCsrfMeta();
    }

    return open.call(this, method, url, ...args);
  }

  patchedOpen.__extraBlocksDirectUploadCsrf = true;
  XMLHttpRequest.prototype.open = patchedOpen;
};

patchXhrOpen();

ensureHeadCsrfMeta();
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", ensureHeadCsrfMeta);
}
