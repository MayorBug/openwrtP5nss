# Cudy P5 OpenWrt with NSS

Hi, real human here

This is my personal, "opinionated" OpenWrt with NSS build for the Cudy P5.
The builder fetches my [OpenWrt source branch][board] and adds modem tools and LuCI. The source branch is based on [kuncy7’s OpenWrt NSS tree](https://github.com/kuncy7/openwrt-nss-edma).
Cudy P5 comes with RM520 modem from factory. I started this project because I wanted upgrade it to RM551.
I can say the builds are experimental, but "stable" enough to be in daily use.
RM520 and RM551 modems are tested, for other PCIe modems feedback is welcome.

I'll do my best to keep this build up to date, since most likely NSS will never be upstreamed due to its closed nature.
Without NSS the router is quite useless. Thats why rn I do not plan to upstream the device support.

For help feel free to comment in the forums or open an issue.
I'll not take responsibility for bricked routers!

AI usage notice, without it this project would not be possible by me. 
The rest is slop

## Choose an image

Choose the image that matches your router’s flash layout.

| Image profile | Flash layout |
| --- | --- |
| `cudy_p5` | Original dual-slot layout. OpenWrt uses one 36 MiB slot. |
| `cudy_p5-ubootmod` | Custom U-Boot with one 120.25 MiB OpenWrt partition after full NAND conversion. |

Custom U-Boot also supports the original layout. If you keep that layout,
use the `cudy_p5` image.

Each build produces three files per profile.

| File suffix | Use |
| --- | --- |
| `squashfs-sysupgrade.bin` | Upgrade OpenWrt on the matching layout. |
| `squashfs-factory.ubi` | Install OpenWrt through the custom U-Boot web recovery page. |
| `initramfs-uImage.itb` | Start OpenWrt from RAM for testing or installation. |

## Back up and install

Save your NAND and partition backups before you replace U-Boot or change
the flash layout. Follow the [backup instructions][backup] in my
[Cudy P5 U-Boot repository][uboot].

- If you are starting from stock firmware and keeping the original layout,
  follow the [stock installation instructions][forum].
- If you want to install custom U-Boot or change layouts, follow my
  [U-Boot installation guide][install]. You can test the bootloader from RAM first.
- If the router already has custom U-Boot, use the [OpenWrt recovery instructions][recovery]
  to install the image for the current layout.

## What is included

| Area | Packages and features |
| --- | --- |
| Web interface | LuCI, [Shadcn theme][shadcn], LuCI Dashboard, and the NSS status page |
| Mobile broadband | [wwand][wwand], its LuCI pages and protocol support, and direct QMI and MBIM over PCIe/MHI |
| USB modem support | USB serial, QMI, MBIM, and CDC Ethernet drivers |
| Network offload | NSS routing and Wi-Fi offload, PPPoE and VLAN support, and NSS queue management |
| Memory | Compressed RAM swap through `zram-swap` |
| Diagnostics | `iperf3`, `ip-full`, `nssinfo`, and `dumpimage` |

## Build defaults

- Both images ship NSS firmware 12.5. The first boot saves that selection.
- Both images use the low NSS memory profile and the extra ath11k NSS memory
  savings for supported radios. OpenWrt still selects the ath11k host profile
  from the RAM Linux can manage. See the [memory guide][memory] for details.
- The MHI driver uses non-burst doorbells for SDX75 modems. The NSS GRO fix
  leaves combined receive packets with Linux for correct forwarding.
- The single-rootfs image lets Linux power the modem. If the modem is
  missing after the initial scan, the boot service waits for the PCIe link
  and rescans the port.
- The images include NSS queue management with the default queue disabled.
- The images include direct QMI and MBIM. QRTR support is a separate package.

## Hardware test

A local full NAND build booted on one P5 after factory UBI installation
through U-Boot recovery. The saved OpenWrt configuration was restored.

## Get a build

Download firmware from [GitHub Releases][releases]. Each release contains
both sets of images, the shared package manifest, and `SHA256SUMS`.
The `source.buildinfo` file records the exact OpenWrt source commit and
builder commit.

Download `SHA256SUMS` into the same directory as the images you need.
Run this command in that directory.

```sh
sha256sum -c --ignore-missing SHA256SUMS
```

If a checksum fails, download the file again before you flash it.

To make a new release, run the [P5 firmware workflow][actions] on `main`.
It builds both layouts with the latest wwand feed and pinned revisions
for the other feeds. The workflow also provides the `cudy-p5-firmware`
archive as a CI artifact.

To build both profiles locally, run these commands in fish from the
repository root on `main`. The preparation script sets the build configuration
and uses the same feed selection.

```fish
git clone --branch cudy-p5-ubootmod https://github.com/MayorBug/openwrt.git openwrt
and .github/ci/p5/prepare.sh openwrt
and make -C openwrt -j(nproc)
```

The images are in `openwrt/bin/targets/qualcommax/ipq50xx/`. The workflow sets the source repository and branch.

[kuncy]: https://github.com/kuncy7/openwrt-nss-edma/blob/c3po-tag-8021q/.github/README.md
[memory]: https://github.com/MayorBug/openwrt/blob/cudy-p5-ubootmod/README.ipq50xx.md#memory-profiles
[wwand]: https://github.com/ddimension/wwand
[shadcn]: https://github.com/eamonxg/luci-theme-shadcn
[uboot]: https://github.com/MayorBug/ubootP5webui
[backup]: https://github.com/MayorBug/ubootP5webui/blob/main/INSTALL.md#3-save-backups
[install]: https://github.com/MayorBug/ubootP5webui/blob/main/INSTALL.md
[recovery]: https://github.com/MayorBug/ubootP5webui/blob/main/INSTALL.md#6-install-openwrt
[actions]: https://github.com/MayorBug/openwrtP5nss/actions/workflows/build-p5.yml
[releases]: https://github.com/MayorBug/openwrtP5nss/releases
[board]: https://github.com/MayorBug/openwrt/tree/cudy-p5-ubootmod
[forum]: https://forum.openwrt.org/t/ipq5018-adding-cudy-p5-support/252655
