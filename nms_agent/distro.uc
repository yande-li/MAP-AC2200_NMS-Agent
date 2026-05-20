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
