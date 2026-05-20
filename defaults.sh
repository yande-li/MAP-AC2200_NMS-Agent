#!/bin/sh

mkdir -p /etc/nms_agent

cat << 'EOF' > /etc/nms_agent/temperature.uc
#!/usr/bin/ucode
const fs = require("fs");
let max_temp = 0;

for (let i = 0; i <= 2; i++) {
    const path = sprintf("/sys/class/hwmon/hwmon%d/temp1_input", i);
    const fp = fs.open(path, "r");
    if (!fp) continue;

    const raw = fp.read("line");
    fp.close();
    if (!raw) continue;

    const val = int(raw);
    if (val > max_temp) {
        max_temp = val;
    }
}

if (max_temp > 0) {
    printf("%.1f", max_temp / 1000);
}
EOF

cat << 'EOF' > /etc/nms_agent/distro.uc
#!/usr/bin/ucode
const fs = require("fs");
const fp = fs.open("/etc/openwrt_release", "r");
let id = "OpenWrt", release = "Unknown";

if (fp) {
    let line;
    while ((line = fp.read("line")) != null) {
        let m = match(line, /^DISTRIB_ID=['"]?([^'"]+)['"]?/);
        if (m) id = m[1];
        
        m = match(line, /^DISTRIB_RELEASE=['"]?([^'"]+)['"]?/);
        if (m) release = m[1];
    }
    fp.close();
}
print(id + " " + release + "\n");
EOF

chmod +x /etc/nms_agent/temperature.uc
chmod +x /etc/nms_agent/distro.uc

exit 0