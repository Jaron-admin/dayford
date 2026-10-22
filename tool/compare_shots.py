"""Place each prototype shot beside the matching implementation golden."""

import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMPL = os.path.join(ROOT, "docs", "screenshots", "0.1")
PROTO = os.path.join(ROOT, "third_party", "design", "shots")
OUT = os.path.join(IMPL, "compare")
HEIGHT = 1624
GAP = 28
LABEL = 48
BG = (237, 234, 229, 255)


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    font_path = os.path.join(
        ROOT, "third_party", "fonts", "noto-sans-sc", "NotoSansSC-Regular.ttf"
    )
    font = ImageFont.truetype(font_path, 28)
    names = sorted(
        name
        for name in os.listdir(IMPL)
        if name.endswith(".png") and not name.startswith("android-")
    )
    written = 0
    for name in names:
        proto_path = os.path.join(PROTO, name)
        if not os.path.exists(proto_path):
            continue
        proto = _fit(Image.open(proto_path).convert("RGBA"))
        impl = _fit(Image.open(os.path.join(IMPL, name)).convert("RGBA"))
        width = proto.width + GAP + impl.width
        canvas = Image.new("RGBA", (width, HEIGHT + LABEL), BG)
        canvas.paste(proto, (0, LABEL), proto)
        canvas.paste(impl, (proto.width + GAP, LABEL), impl)
        draw = ImageDraw.Draw(canvas)
        draw.text((16, 10), "原型", font=font, fill=(20, 20, 20, 255))
        draw.text((proto.width + GAP + 16, 10), "实现", font=font, fill=(20, 20, 20, 255))
        canvas.convert("RGB").save(os.path.join(OUT, name), optimize=True)
        written += 1
    print(f"wrote {written} comparisons to {OUT}")


def _fit(image: Image.Image) -> Image.Image:
    ratio = HEIGHT / image.height
    size = (max(1, round(image.width * ratio)), HEIGHT)
    return image.resize(size, Image.Resampling.LANCZOS)


if __name__ == "__main__":
    main()
