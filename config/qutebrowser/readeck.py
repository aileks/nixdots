"""Open Readeck's URL-saving form using the browser's existing login."""

import os
from urllib.parse import urlencode, urlsplit


def main():
    url = os.environ.get("QUTE_URL", "")
    if urlsplit(url).scheme not in ("http", "https"):
        command = "message-error 'Readeck: open an HTTP or HTTPS page first'"
    else:
        target = "http://hostghost.local:8000/bookmarks?" + urlencode({"url": url})
        command = "open -t " + target
    with open(os.environ["QUTE_FIFO"], "w", encoding="utf-8") as fifo:
        fifo.write(command + "\n")


if __name__ == "__main__":
    main()
