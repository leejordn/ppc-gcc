#! /usr/bin/env python3

import os
import subprocess
import urllib.parse


def maybe_download(file_name: str, url: str) -> bool:
    """Download `file` from `url` if it doesn't already exist"""
    if os.path.exists(file_name):
        print(f"Skipping existing file \"{file_name}\"...")
    else:
        print(f"Downloading {file_name} from \"{url}\"...")
        try:
            subprocess.run(["curl", "-O", "--progress-bar", url], check=True)
        except subprocess.CalledProcessError as e:
            print(f"\nFailed to download {url}: {e}")
            return false
    return True


def fetch_sources(filename: str) -> bool:
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if not line or "=" not in line:
                print(line)
                continue
            name, url = line.split("=", 1)
            if url.endswith("/"):
                tarball = name + ".tar.xz"
                full_url = urlllib.parse.urljoin(url, tarball)
            else:
                full_url = url
                tarball = os.path.basename(urllib.parse.urlparse(url).path)
            if not maybe_download(tarball, url):
                print(f"Received error - exiting...")
                return False
    return True


if __name__ == "__main__":
    if not fetch_sources("manifest.txt"):
        exit(1)
