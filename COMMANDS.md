Download all `.mp3` files from a YouTube playlist.

```sh
yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --yes-playlist <url>
```

Download all exercises for an exercism track

```sh
track=$TRACK_NAME; curl "https://exercism.org/api/v2/tracks/$track/exercises" | \     ~/exercism/rust
  jq -r '.exercises[].slug' | \
  xargs -I {} -n1 sh -c "exercism download --track=$track --exercise {} || true"
```

Nix needs to know hash of files. Here's how we can get it:

```sh
nix-prefetch-url --unpack https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F7350/pdfium-v8-linux-x64.tgz
```
