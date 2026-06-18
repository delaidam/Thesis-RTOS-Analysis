#!/usr/bin/env python3
"""Generate a small RMS schedulability/overload demo for presentation slides.

This is an analytical fixed-priority Rate Monotonic Scheduling (RMS) example.
It is not a Tang Nano hardware or FreeRTOS runtime measurement.
"""

from __future__ import annotations

import csv
import math
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "0.doc" / "data"
ASSET_DIR = ROOT / "0.doc" / "presentation_assets"

TASKS = [
    ("sensor", 10.0, 2.0),
    ("control", 20.0, 4.0),
    ("logging", 50.0, 8.0),
]

SCALES = [0.50, 0.75, 1.00, 1.25, 1.40, 1.50, 1.60, 1.70, 1.75, 1.90, 2.00]
RM_BOUND = len(TASKS) * (2 ** (1 / len(TASKS)) - 1)


def response_time_analysis(tasks: list[tuple[str, float, float]]) -> tuple[bool, list[float]]:
    responses: list[float] = []

    for index, (_, period, wcet) in enumerate(tasks):
        response = wcet

        for _ in range(100):
            interference = sum(
                math.ceil(response / higher_period) * higher_wcet
                for _, higher_period, higher_wcet in tasks[:index]
            )
            next_response = wcet + interference

            if next_response == response:
                break

            response = next_response

            if response > period:
                break

        responses.append(response)

    schedulable = all(response <= tasks[i][1] for i, response in enumerate(responses))
    return schedulable, responses


def build_rows() -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []

    for scale in SCALES:
        scaled = [(name, period, wcet * scale) for name, period, wcet in TASKS]
        utilization = sum(wcet / period for _, period, wcet in scaled)
        schedulable, responses = response_time_analysis(scaled)
        max_ratio = max(response / scaled[i][1] for i, response in enumerate(responses))

        if utilization > 1.0:
            region = "overload"
        elif not schedulable:
            region = "deadline_miss"
        elif utilization <= RM_BOUND:
            region = "guaranteed_by_bound"
        else:
            region = "schedulable_above_bound"

        rows.append(
            {
                "scale": scale,
                "utilization": utilization,
                "rm_bound": RM_BOUND,
                "schedulable": int(schedulable),
                "region": region,
                "sensor_response_ms": responses[0],
                "control_response_ms": responses[1],
                "logging_response_ms": responses[2],
                "max_response_deadline_ratio": max_ratio,
            }
        )

    return rows


def write_csv(rows: list[dict[str, object]]) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = DATA_DIR / "rms_overload_summary.csv"

    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def chart_points(rows: list[dict[str, object]], x0: float, y0: float, width: float, height: float) -> list[tuple[float, float]]:
    xmin, xmax = 0.25, 1.15
    ymin, ymax = 0.0, 1.35
    points = []

    for row in rows:
        x = x0 + ((float(row["utilization"]) - xmin) / (xmax - xmin)) * width
        y = y0 + height - ((float(row["max_response_deadline_ratio"]) - ymin) / (ymax - ymin)) * height
        points.append((x, y))

    return points


def write_svg(rows: list[dict[str, object]]) -> None:
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    path = ASSET_DIR / "rms_overload_failure.svg"

    x0, y0, width, height = 170.0, 205.0, 850.0, 340.0
    xmin, xmax = 0.25, 1.15

    def x_for_util(utilization: float) -> float:
        return x0 + ((utilization - xmin) / (xmax - xmin)) * width

    points = chart_points(rows, x0, y0, width, height)
    polyline = " ".join(f"{x:.1f},{y:.1f}" for x, y in points)

    point_nodes = []
    for row, (x, y) in zip(rows, points):
        region = str(row["region"])
        color = {
            "guaranteed_by_bound": "#2f6fed",
            "schedulable_above_bound": "#f2a541",
            "deadline_miss": "#e63946",
            "overload": "#9d0208",
        }[region]
        point_nodes.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="7" fill="{color}"/>')

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="720" viewBox="0 0 1200 720" role="img" aria-label="RMS overload and deadline miss demonstration">
  <rect width="1200" height="720" fill="#f7f9fc"/>
  <rect x="70" y="55" width="1060" height="610" rx="24" fill="#ffffff" stroke="#d9e2ef"/>

  <text x="95" y="110" font-family="Inter, Arial, sans-serif" font-size="36" font-weight="700" fill="#152238">RMS overload: when deadlines start to fail</text>
  <text x="95" y="146" font-family="Inter, Arial, sans-serif" font-size="19" fill="#526071">Analytical Rate Monotonic Scheduling sweep; not a Tang Nano FreeRTOS runtime measurement.</text>

  <rect x="{x0:.1f}" y="{y0:.1f}" width="{x_for_util(RM_BOUND)-x0:.1f}" height="{height:.1f}" fill="#eef6ff"/>
  <rect x="{x_for_util(RM_BOUND):.1f}" y="{y0:.1f}" width="{x_for_util(1.0)-x_for_util(RM_BOUND):.1f}" height="{height:.1f}" fill="#fff8e6"/>
  <rect x="{x_for_util(1.0):.1f}" y="{y0:.1f}" width="{x0+width-x_for_util(1.0):.1f}" height="{height:.1f}" fill="#fff1f1"/>

  <line x1="{x0:.1f}" y1="{y0+height:.1f}" x2="{x0+width:.1f}" y2="{y0+height:.1f}" stroke="#203047" stroke-width="2"/>
  <line x1="{x0:.1f}" y1="{y0:.1f}" x2="{x0:.1f}" y2="{y0+height:.1f}" stroke="#203047" stroke-width="2"/>

  <line x1="{x0:.1f}" y1="{y0+height-(1.0/1.35)*height:.1f}" x2="{x0+width:.1f}" y2="{y0+height-(1.0/1.35)*height:.1f}" stroke="#e63946" stroke-width="3" stroke-dasharray="8 8"/>
  <text x="{x0+width-5:.1f}" y="{y0+height-(1.0/1.35)*height-10:.1f}" text-anchor="end" font-family="Inter, Arial, sans-serif" font-size="16" font-weight="700" fill="#e63946">deadline boundary</text>

  <line x1="{x_for_util(RM_BOUND):.1f}" y1="{y0:.1f}" x2="{x_for_util(RM_BOUND):.1f}" y2="{y0+height:.1f}" stroke="#2f6fed" stroke-width="2" stroke-dasharray="7 7"/>
  <line x1="{x_for_util(1.0):.1f}" y1="{y0:.1f}" x2="{x_for_util(1.0):.1f}" y2="{y0+height:.1f}" stroke="#9d0208" stroke-width="2" stroke-dasharray="7 7"/>

  <polyline points="{polyline}" fill="none" stroke="#203047" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>
  {"".join(point_nodes)}

  <g font-family="Inter, Arial, sans-serif" font-size="15" fill="#6b778c">
    <text x="{x0-50:.1f}" y="{y0+height+5:.1f}">0.0</text>
    <text x="{x0-50:.1f}" y="{y0+height-(0.5/1.35)*height+5:.1f}">0.5</text>
    <text x="{x0-50:.1f}" y="{y0+height-(1.0/1.35)*height+5:.1f}">1.0</text>
    <text x="{x0-50:.1f}" y="{y0+height-(1.3/1.35)*height+5:.1f}">1.3</text>
    <text x="{x0:.1f}" y="{y0+height+35:.1f}">CPU utilization</text>
    <text transform="translate(105 420) rotate(-90)" font-size="16">max response / deadline</text>
  </g>

  <text x="{x_for_util(RM_BOUND):.1f}" y="{y0+height+35:.1f}" text-anchor="middle" font-family="Inter, Arial, sans-serif" font-size="15" fill="#2f6fed">RM bound approx {RM_BOUND:.2f}</text>
  <text x="{x_for_util(1.0):.1f}" y="{y0+height+35:.1f}" text-anchor="middle" font-family="Inter, Arial, sans-serif" font-size="15" fill="#9d0208">U = 1.0</text>

  <rect x="150" y="600" width="900" height="36" rx="18" fill="#f2f5f9"/>
  <text x="600" y="624" text-anchor="middle" font-family="Inter, Arial, sans-serif" font-size="16" fill="#203047">Use only as a labeled analytical/simulation slide: it shows why overload creates deadline misses.</text>
</svg>
"""
    path.write_text(svg)


def main() -> None:
    rows = build_rows()
    write_csv(rows)
    write_svg(rows)
    print(f"Wrote {DATA_DIR / 'rms_overload_summary.csv'}")
    print(f"Wrote {ASSET_DIR / 'rms_overload_failure.svg'}")


if __name__ == "__main__":
    main()
