# live-demo

The sample gallery published to GitHub Pages by
`.github/workflows/pages.yml`: every wasm-capable sample on one page.

- `index.html`: the gallery.

- `run.html`: runs one sample: `run.html?app=cube_sapp`, or
  `run.html?app=cube_sapp&backend=wgpu` for the WebGPU build.

- `thumbs/*.jpg`: screenshots of the native builds, committed here.

- `favicon.svg` (gallery) and `sokol_icon.png` (sample pages): the minc
  mark and sokol_app's default icon; a sample calling `sapp_set_icon`
  overrides its own tab.

- The `.wasm` files, the wasm host and `data/` are staged by the
  workflow at deploy time, not committed.
