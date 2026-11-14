# Slim OpenHarmony runtime for Linkspan

A slim OpenHarmony standard system that can install a HAP with bm and aa. This is not a HarmonyOS commercial image. Do not fetch Huawei update packages or signing keys.

The scripts here are Apache-2.0, Copyright 2026 Ye Zicheng. The image they build is not committed. Linkspan downloads a published GitHub Release of this repository at runtime. A China mirror is selected by Linkspan from the client IP. The mirror must serve the same bytes. Linkspan checks SHA-256.

The official site is https://olympium.net. Do not commit `*.img`, `*.tar.gz`, certificates, or keys.

## Build

```bash
./build-slim.sh
```


1. Build the OpenHarmony standard system from the upstream OpenHarmony manifest, product `linkspan_slim`, with developer mode enabled and no store client.
2. Write an `EDITION` file whose text contains `openharmony-slim`, the version, and `developer-mode`.
3. Pack `system.img`, `vendor.img`, `userdata.img`, `EDITION`, `bin/hdc`, `bin/linkspan-runtime`, and `bin/linkspan-surface`.
4. `linkspan-runtime` starts QEMU with `-display none`. `linkspan-surface` is the host window. If it cannot attach to the guest, it must exit. It must not open an emulator frame.
5. Refuse any input file whose name or manifest says HarmonyOS.


After a build, fill `sha256` in `runtime-lock.json`, set `"published": true` in this file and in Linkspan's `share/runtime-lock.json`, tag `v0.1.0`, and attach the `.tar.gz` assets to the GitHub Release. Until that release exists, Linkspan reports that the image is not published.

## Assets

- `openharmony-slim-x86_64.tar.gz`
- `openharmony-slim-aarch64.tar.gz`
