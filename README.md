# MAP-AC2200_NMS-Agent
These ucode and shell (ash) scripts enable LibreNMS monitoring for the Asus Lyra (MAP-AC2200) running OpenWrt.

### Requirements
- **Hardware:** [Asus Lyra (MAP-AC2200)](https://openwrt.org/toh/asus/lyra_map-ac2200)
- **OS:** OpenWrt 23.05 or higher
- **Software:** `snmpd` package must be installed


## Usage

The [`defaults.sh`](defaults.sh) script is designed for use with the [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org). While it's primarily intended to be embedded during the firmware build process, it can also be manually run on OpenWrt.

### Installation Steps

1. **Install SNMPD:**  
   - **Method 1: Using [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org)**: 
        1. Add `snmpd` to the **Installed Packages** field. Example:
            ```
            apk-mbedtls ath10k-board-qca4019 ath10k-firmware-qca4019-ct base-files ca-bundle dnsmasq dropbear firewall4 fstools kmod-ath10k-ct kmod-gpio-button-hotplug kmod-leds-gpio kmod-nft-offload kmod-usb-dwc3 kmod-usb-dwc3-qcom kmod-usb3 libc libgcc libustream-mbedtls logd mtd netifd nftables odhcp6c odhcpd-ipv6only ppp ppp-mod-pppoe procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-mbedtls ath10k-firmware-qca9888-ct kmod-ath3k luci luci-app-attendedsysupgrade snmpd
            ```
        2. Place the [`defaults.sh`](defaults.sh) script in the **"Script to run on first boot (uci-defaults)"** section.  
            And then click the **"REQUEST BUILD"** button at the bottom to generate and download your custom firmware.
   - **Method 2: For an existing OpenWrt installation**
        1. Ensure the `snmpd` package is installed on your OpenWrt device. You can enter the command to install the `snmpd` package, as follows:
        
            #### OpenWrt >= 25.12
            ```shell
            apk update
            apk add snmpd
            ```
        
            #### OpenWrt < 25.12
            ```shell
            opkg update
            opkg install snmpd
            ```

        2. Upload [`defaults.sh`](defaults.sh) to your OpenWrt device and run the commands:
            ```shell
            chmod 755 defaults.sh
            ./defaults.sh
            ```

2. **Post-Installation Configuration:**  
   After flashing and booting the new firmware, append the following configuration to the end of `/etc/config/snmpd`:

   ```config
   config extend
	   option name 'hardware'
	   option prog '/bin/cat'
	   option args '/sys/firmware/devicetree/base/model'

   config extend
       option name 'distro'
       option prog '/etc/nms_agent/distro.uc'

   config extend
       option name 'temperature'
       option prog '/etc/nms_agent/temperature.uc'
    Apply the changes by restarting the `snmpd` service:
    ```shell
    /etc/init.d/snmpd restart
    ```


### Testing:
You can verify the monitoring setup by running `snmpwalk` from your LibreNMS server. Example:
```shell
snmpwalk -On -v 2c -c public <OpenWrt_IP> 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."temperature"'

snmpwalk -On -v 2c -c public <OpenWrt_IP> 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."distro"'
```

#### Expected Output:
```shell
librenms:/opt/librenms$ snmpwalk -On -v 2c -c public <OpenWrt_IP> 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."temperature"'
.1.3.6.1.4.1.8072.1.3.2.3.1.2.11.116.101.109.112.101.114.97.116.117.114.101 = STRING: 74.0
librenms:/opt/librenms$ snmpwalk -On -v 2c -c public <OpenWrt_IP>  'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."distro"'
.1.3.6.1.4.1.8072.1.3.2.3.1.2.6.100.105.115.116.114.111 = STRING: OpenWrt 25.12.4
```

 - Temperature's OID: `.1.3.6.1.4.1.8072.1.3.2.3.1.2.11.116.101.109.112.101.114.97.116.117.114.101`
 - Distro's OID: `.1.3.6.1.4.1.8072.1.3.2.3.1.2.6.100.105.115.116.114.111`
