# Slim OpenHarmony runtime for Linkspan

A slim OpenHarmony standard system that can install a HAP with bm and aa. This is not a HarmonyOS commercial image. Do not fetch Huawei update packages or signing keys.

The scripts here are Apache-2.0, Copyright 2026 Ye Zicheng. The image they build is not committed. Linkspan downloads a published GitHub Release of this repository at runtime. A China mirror is selected by Linkspan from the client IP. The mirror must serve the same bytes. Linkspan checks SHA-256.

The official site is https://olympium.net. Do not commit `*.img`, `*.tar.gz`, certificates, or keys.

## Build

```bash
./build-slim.sh
```

The script packs `system.img`, `vendor.img`, `userdata.img`, and `hdc` from `OHOS_IMAGES` only when that directory is a local OpenHarmony standard-system build whose identity text says OpenHarmony and does not say HarmonyOS. It does not download a HarmonyOS package, a Huawei update, or a third-party disk image. It does not write a placeholder archive.

No image was built for 0.1.0. An upstream standard-system build asks for about 32 GiB of RAM and 16 cores. The host used here has 4 vCPU and 16 GiB of RAM, which is below that. `published` stays false and `sha256` stays empty.

## Assets

- `openharmony-slim-x86_64.tar.gz`
- `openharmony-slim-aarch64.tar.gz`
