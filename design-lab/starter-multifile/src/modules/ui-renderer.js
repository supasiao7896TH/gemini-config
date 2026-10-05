/* 5 · UI_RENDERER — ที่เดียวที่แตะ DOM */

/* กัน XSS: ข้อความจากผู้ใช้/ฐานข้อมูลต้องผ่าน textContent เท่านั้น ห้าม innerHTML */
function el(tag, cls, text) {
  const n = document.createElement(tag);
  if (cls) n.className = cls;
  if (text != null) n.textContent = String(text);
  return n;
}

function kpi(item) {
  const c = el("div", "card kpi");
  c.appendChild(el("div", "k-label", item.label));
  const v = el("div", "k-val");
  v.appendChild(el("span", null, item.value));
  v.appendChild(el("span", "k-unit", item.unit));
  c.appendChild(v);
  const chip = el("span", `chip ${item.tone}`, item.note);
  const foot = el("div", null);
  foot.style.marginTop = "8px";
  foot.appendChild(chip);
  c.appendChild(foot);
  return c;
}

function row(r) {
  const tr = el("tr");
  const td0 = el("td");
  td0.appendChild(el("span", "chip c-ref", r.tag));
  tr.appendChild(td0);
  tr.appendChild(el("td", null, r.name));
  tr.appendChild(el("td", "num", r.value));
  const td3 = el("td");
  td3.appendChild(el("span", `chip ${r.tone}`, r.status));
  tr.appendChild(td3);
  return tr;
}

export const UiRenderer = {
  el,
  render(state) {
    const kpiRow = document.getElementById("kpiRow");
    const body = document.getElementById("tblBody");
    kpiRow.textContent = "";
    body.textContent = "";
    state.kpis.forEach((k) => kpiRow.appendChild(kpi(k)));
    state.records.forEach((r) => body.appendChild(row(r)));
  }
};
