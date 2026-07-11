#!/usr/bin/env python3
"""Build selected firmware targets for RV32IM/RV32IMC and chart code size."""

from __future__ import annotations

import csv
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "0.doc" / "data"
ASSET_DIR = ROOT / "0.doc" / "presentation_assets"

APPS = [
    "timer_hello",
    "irq_hello",
    "poll_benchmark",
    "irq_benchmark",
    "event_alert_demo",
    "workload_sweep_demo",
    "main",
]

ARCHES = ["rv32im", "rv32imc"]


def run(cmd: list[str]) -> str:
    completed = subprocess.run(
        cmd,
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return completed.stdout


def parse_size(output: str, app: str) -> dict[str, int]:
    for line in output.splitlines():
        if line.endswith(f"2.sw/{app}.elf"):
            parts = line.split()
            return {
                "text": int(parts[0]),
                "data": int(parts[1]),
                "bss": int(parts[2]),
                "dec": int(parts[3]),
            }

    raise RuntimeError(f"could not parse size output for {app}")


def build_sizes() -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []

    for app in APPS:
        by_arch: dict[str, dict[str, int]] = {}

        for arch in ARCHES:
            run(["make", "-B", "firmware", f"APP={app}", "CROSS=riscv-none-elf-", f"MARCH={arch}"])
            size_output = run(["riscv-none-elf-size", f"2.sw/{app}.elf"])
            by_arch[arch] = parse_size(size_output, app)

        im_text = by_arch["rv32im"]["text"]
        imc_text = by_arch["rv32imc"]["text"]
        reduction = 100.0 * (im_text - imc_text) / im_text

        rows.append(
            {
                "firmware": app,
                "rv32im_text": im_text,
                "rv32imc_text": imc_text,
                "rv32im_bss": by_arch["rv32im"]["bss"],
                "rv32imc_bss": by_arch["rv32imc"]["bss"],
                "text_reduction_percent": f"{reduction:.1f}",
            }
        )

    return rows


def write_csv(rows: list[dict[str, object]]) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = DATA_DIR / "rv32im_vs_rv32imc_sizes.csv"

    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def write_svg(rows: list[dict[str, object]]) -> None:
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    path = ASSET_DIR / "rv32im_vs_rv32imc_multi.svg"

    max_text = max(int(row["rv32im_text"]) for row in rows)
    y_start = 205
    row_gap = 58
    bar_x = 325
    bar_w = 565
    im_h = 18
    imc_h = 18

    row_nodes = []
    for i, row in enumerate(rows):
        y = y_start + i * row_gap
        im_text = int(row["rv32im_text"])
        imc_text = int(row["rv32imc_text"])
        im_width = bar_w * im_text / max_text
        imc_width = bar_w * imc_text / max_text
        firmware = str(row["firmware"]).replace("_", " ")
        reduction = str(row["text_reduction_percent"])

        row_nodes.append(
            f"""
  <text x="105" y="{y+17}" font-family="Inter, Arial, sans-serif" font-size="17" fill="#203047">{firmware}</text>
  <rect x="{bar_x}" y="{y}" width="{im_width:.1f}" height="{im_h}" rx="5" fill="#2f6fed"/>
  <rect x="{bar_x}" y="{y+23}" width="{imc_width:.1f}" height="{imc_h}" rx="5" fill="#17a398"/>
  <text x="{bar_x + im_width + 12:.1f}" y="{y+15}" font-family="Inter, Arial, sans-serif" font-size="15" fill="#526071">{im_text} B</text>
  <text x="{bar_x + imc_width + 12:.1f}" y="{y+38}" font-family="Inter, Arial, sans-serif" font-size="15" fill="#526071">{imc_text} B</text>
  <text x="1040" y="{y+28}" text-anchor="end" font-family="Inter, Arial, sans-serif" font-size="16" font-weight="700" fill="#17a398">{reduction}%</text>
"""
        )

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="720" viewBox="0 0 1200 720" role="img" aria-label="RV32IM versus RV32IMC firmware size sweep">
  <rect width="1200" height="720" fill="#f7f9fc"/>
  <rect x="70" y="55" width="1060" height="610" rx="24" fill="#ffffff" stroke="#d9e2ef"/>
  <text x="95" y="110" font-family="Inter, Arial, sans-serif" font-size="36" font-weight="700" fill="#152238">RV32IM vs RV32IMC across firmware targets</text>
  <text x="95" y="146" font-family="Inter, Arial, sans-serif" font-size="19" fill="#526071">Code-size sweep generated from reproducible builds; bars show .text bytes.</text>

  <rect x="325" y="165" width="18" height="18" rx="5" fill="#2f6fed"/>
  <text x="350" y="180" font-family="Inter, Arial, sans-serif" font-size="16" fill="#203047">RV32IM</text>
  <rect x="435" y="165" width="18" height="18" rx="5" fill="#17a398"/>
  <text x="460" y="180" font-family="Inter, Arial, sans-serif" font-size="16" fill="#203047">RV32IMC</text>
  <text x="1040" y="180" text-anchor="end" font-family="Inter, Arial, sans-serif" font-size="16" fill="#526071">.text reduction</text>

  {"".join(row_nodes)}

  <rect x="165" y="640" width="870" height="38" rx="19" fill="#fff8e6" stroke="#f2c94c"/>
  <text x="600" y="665" text-anchor="middle" font-family="Inter, Arial, sans-serif" font-size="16" fill="#7a5b00">Use this when you need a stronger claim than a single-firmware example.</text>
</svg>
"""
    path.write_text(svg)


def main() -> None:
    rows = build_sizes()
    write_csv(rows)
    write_svg(rows)
    print(f"Wrote {DATA_DIR / 'rv32im_vs_rv32imc_sizes.csv'}")
    print(f"Wrote {ASSET_DIR / 'rv32im_vs_rv32imc_multi.svg'}")


if __name__ == "__main__":
    main()
