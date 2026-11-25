#!/bin/sh
set -eu

ci=.github/ci/p5
cp "$ci/feeds.conf" feeds.conf
./scripts/feeds update -a

patch_file=0199-nss-rmnet-preserve-gro-packet-boundaries.patch
cp "$ci/patches/$patch_file" "feeds/nss/qca-nss-drv/patches/$patch_file"
sed -i 's/^PKG_RELEASE:=23$/PKG_RELEASE:=24/' feeds/nss/qca-nss-drv/Makefile
grep -qx 'PKG_RELEASE:=24' feeds/nss/qca-nss-drv/Makefile
./scripts/feeds install -a
# These optional packages in the pinned feeds have Kconfig dependency cycles.
./scripts/feeds uninstall luci-app-fwknopd wwand-rsim

theme=package/luci-theme-shadcn
theme_revision=1830d0a78b74709a1214565f56cfe50a6a9a0084
if [ ! -d "$theme/.git" ]; then
	git clone --no-checkout --depth 1 https://github.com/eamonxg/luci-theme-shadcn.git "$theme"
fi
git -C "$theme" fetch --depth 1 origin "$theme_revision"
git -C "$theme" checkout --detach "$theme_revision"

common=.github/ci/ipq50xx/common.config
cat "$common" "$ci/p5.config" > .config
make defconfig

for fragment in "$common" "$ci/p5.config"; do
	while IFS= read -r line; do
		case "$line" in
			CONFIG_*=*|'# CONFIG_PACKAGE_kmod-qrtr-mhi is not set')
				grep -Fxq "$line" .config || {
					printf 'Missing build option: %s\n' "$line" >&2
					exit 1
				}
				;;
		esac
	done < "$fragment"
done
