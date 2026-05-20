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
