# Cudy P5 OpenWrt with NSS

This is my personal, opinionated OpenWrt build for the Cudy P5. It is based
on [Kuncy7's OpenWrt NSS tree][kuncy]. I add [wwand][wwand] for modem
management, the [Shadcn theme][shadcn], and the LuCI dashboard. The build
also includes the SDX75 non-burst patch and the NSS fix for GRO packets
from the upstream MHI data path.

## Choose your image

| Sysupgrade filename ends with | Router layout |
| --- | --- |
| `cudy_p5-squashfs-sysupgrade.bin` | Stock dual-slot layout, with a 36 MiB OpenWrt rootfs |
| `cudy_p5-ubootmod-squashfs-sysupgrade.bin` | Custom U-Boot after conversion to one 72 MiB rootfs |

Choose the image by the router's **flash layout**. Custom U-Boot can also
run the original dual-slot layout. Follow the [U-Boot installation
guide][install] if you want to RAM-test U-Boot or convert the layout.

Use `sysupgrade.bin` for upgrades from OpenWrt on the matching profile.
For the first install with the stock layout, follow the [stock install
procedure][forum].
For the first install on the single-rootfs profile, use the matching
factory UBI or initramfs through custom U-Boot recovery. The experimental
single-rootfs builds used the stock board ID. Use recovery to switch
from those builds to the new profile.

## Builds

The [firmware workflow][actions] builds both profiles from pinned feed
revisions. Each successful run provides the images, manifests, build
metadata, and SHA-256 checksums in its `cudy-p5-firmware` artifact.

To build locally from `main` in fish:

```fish
.github/ci/p5/prepare.sh
make -j(nproc)
```

Images are written to `bin/targets/qualcommax/ipq50xx/`.

The [board support branch][board] contains the U-Boot-mod profile for
review upstream. The personal package selection and CI live on `main`.

[kuncy]: https://github.com/kuncy7/openwrt-nss-edma
[wwand]: https://github.com/ddimension/wwand
[shadcn]: https://github.com/eamonxg/luci-theme-shadcn
[install]: https://github.com/MayorBug/ubootP5webui/blob/main/INSTALL.md
[actions]: https://github.com/MayorBug/openwrtP5nss/actions/workflows/build-p5.yml
[board]: https://github.com/MayorBug/openwrtP5nss/tree/cudy-p5-ubootmod
[forum]: https://forum.openwrt.org/t/ipq5018-adding-cudy-p5-support/252655
