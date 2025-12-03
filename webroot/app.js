// webroot/app.js (ES module)
const MOD_ROOT = "/data/adb/modules/anxinity_powerflux";
const endpoints = {
  apply: `${MOD_ROOT}/scripts/apply_profile.sh`,
  status: `${MOD_ROOT}/scripts/get_status.sh`
};

const $ = id => document.getElementById(id);
const gaugeFill = document.getElementById("gauge-fill");
const gaugeValue = document.getElementById("gauge-value");

function runShell(cmd) {
  try {
    if (typeof exec === "function") {
      // KernelSU provides exec binding
      return exec(cmd);
    }
    // Try fetch to KSU local endpoint (some KSU expose /ksu/exec)
    // This is a best-effort fallback; adjust if your KSU uses different endpoint
    const r = fetch("/ksu/exec", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ cmd })
    }).then(r => r.json()).catch(e => ({ errno:1, stdout:"", stderr:String(e) }));
    return r;
  } catch (e) {
    return { errno: 1, stdout: "", stderr: String(e) };
  }
}

function parseStdout(stdout) {
  const lines = (stdout||"").trim().split("\n");
  const data = {};
  lines.forEach(l => {
    const i = l.indexOf("=");
    if (i>-1) data[l.slice(0,i)] = l.slice(i+1);
  });
  return data;
}

async function loadStatus() {
  const r = await Promise.resolve(runShell(`sh ${endpoints.status}`));
  if (!r || r.errno !== 0) {
    // show offline
    $("status-profile").textContent = "—";
    $("status-watt").textContent = "— W";
    return;
  }
  const data = parseStdout(r.stdout || "");
  $("status-profile").textContent = (data.profile_watt || "--") + " W";
  $("status-current").textContent = (data.current_ua || "0") + " µA";
  $("status-voltage").textContent = (data.voltage_uv || "0") + " µV";
  $("status-node").textContent = data.node_current || "not detected";
  const watt = Number(data.current_watt || 0);
  gaugeValue.textContent = (watt || "--") + " W";
  // animate gauge: map 0..150W to stroke-dashoffset 565..0
  const max = 150;
  const pct = Math.min(1, watt / max);
  const offset = Math.round(565 * (1 - pct));
  const el = document.getElementById("gauge-fill");
  if (el) el.style.transition = "stroke-dashoffset 600ms cubic-bezier(.22,.9,.3,1)";
  el.setAttribute("style", `stroke-dashoffset:${offset}`);
  // set select to current profile
  if (data.profile_watt) $("watt-select").value = data.profile_watt;
}

async function applyProfile() {
  const val = $("watt-select").value;
  const btn = $("apply-btn");
  btn.disabled = true; btn.textContent = "Applying…";
  const r = await Promise.resolve(runShell(`sh ${MOD_ROOT}/scripts/apply_profile.sh ${val}`));
  btn.disabled = false; btn.textContent = "Apply Profile";
  if (r && r.errno === 0 && (r.stdout||"").trim() === "ok") {
    alert(`Profile set to ${val}W ⚡`);
    loadStatus();
  } else {
    alert("Failed to apply profile. Check module log at /data/adb/anxinity_powerflux/log.txt");
    console.error(r);
  }
}
$("apply-btn").addEventListener("click", applyProfile);
loadStatus();
setInterval(loadStatus, 3000);
