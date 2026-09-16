import argparse
import json
import sys
from pathlib import Path

import pandas as pd


def log(msg):
    print(msg, file=sys.stderr)


def find_table(export_dir: Path, direction: str) -> Path | None:
    patterns = {
        "forward": [
            "*forward*seven*number*summaries*.tsv",
            "*forward*quality*.tsv",
            "*forward*.tsv",
        ],
        "reverse": [
            "*reverse*seven*number*summaries*.tsv",
            "*reverse*quality*.tsv",
            "*reverse*.tsv",
        ],
    }

    for pattern in patterns[direction]:
        matches = list(export_dir.rglob(pattern))
        if matches:
            return matches[0]

    return None


def read_quality_table(
    path: Path,
    quality_quantile: str = "25%"
) -> pd.DataFrame:

    # Read QIIME2 exported summary table
    df = pd.read_csv(path, sep="\t", index_col=0)

    # ------------------------------------------------------------------
    # Case 1:
    # QIIME2 demux format
    #
    # rows    = count, 2%, 9%, 25%, 50%, 75%, ...
    # columns = positions
    # ------------------------------------------------------------------
    if quality_quantile in df.index:

        quality_row = df.loc[quality_quantile]

        out = pd.DataFrame({
            "position": pd.to_numeric(
                quality_row.index,
                errors="coerce"
            ),
            "quality": pd.to_numeric(
                quality_row.values,
                errors="coerce"
            ),
        })

        out = out.dropna().sort_values("position")

        # QIIME2 positions usually start at 0
        # DADA2 trunc_len is read length
        if out["position"].min() == 0:
            out["position"] = out["position"] + 1

        return out

    # ------------------------------------------------------------------
    # Case 2:
    # alternative long-format table
    #
    # columns = position, 25%, 50%, ...
    # ------------------------------------------------------------------
    df = pd.read_csv(path, sep="\t")

    df.columns = [str(c).strip() for c in df.columns]

    position_col = None

    for c in df.columns:
        if c.lower() in {"position", "base", "cycle"}:
            position_col = c
            break

    if position_col is None:
        raise ValueError(
            f"No position/base/cycle column found and "
            f"no '{quality_quantile}' row found in {path}"
        )

    quality_col = None

    # Prefer requested quantile
    candidate_order = [
        quality_quantile,
        "25%",
        "9%",
        "50%",
        "median",
        "Median",
        "mean",
        "Mean",
    ]

    for candidate in candidate_order:
        if candidate in df.columns:
            quality_col = candidate
            break

    if quality_col is None:
        raise ValueError(
            f"No usable quality column found in {path}. "
            f"Available columns: {list(df.columns)}"
        )

    out = df[[position_col, quality_col]].copy()

    out.columns = ["position", "quality"]

    out["position"] = pd.to_numeric(
        out["position"],
        errors="coerce"
    )

    out["quality"] = pd.to_numeric(
        out["quality"],
        errors="coerce"
    )

    out = out.dropna().sort_values("position")

    return out


def estimate_trunc_len(
    qdf: pd.DataFrame,
    quality_threshold: float = 25,
    window: int = 5,
    min_len: int = 50,
) -> int:

    qdf = qdf.copy()

    qdf["rolling_quality"] = (
        qdf["quality"]
        .rolling(window=window, center=True, min_periods=1)
        .median()
    )

    below = qdf["rolling_quality"] < quality_threshold

    if not below.any():
        return int(qdf["position"].max())

    first_bad_index = below.idxmax()

    trunc_len = int(qdf.loc[first_bad_index, "position"]) - 1

    return max(trunc_len, min_len)


def main():

    parser = argparse.ArgumentParser(
        description="Estimate DADA2 truncation lengths from exported QIIME2 demux summary tables."
    )

    parser.add_argument("--export-dir", required=True)

    parser.add_argument(
        "--amplicon-length",
        type=int,
        required=True,
    )

    parser.add_argument(
        "--min-overlap",
        type=int,
        default=20,
    )

    parser.add_argument(
        "--quality-threshold",
        type=float,
        default=25,
    )

    parser.add_argument(
        "--window",
        type=int,
        default=5,
    )

    parser.add_argument(
        "--output-format",
        choices=["json", "shell"],
        default="json",
    )

    args = parser.parse_args()

    export_dir = Path(args.export_dir)

    f_table = find_table(export_dir, "forward")
    r_table = find_table(export_dir, "reverse")

    if f_table is None:
        raise FileNotFoundError(
            "Could not find forward quality summary table."
        )

    log(f"INFO: Forward table: {f_table}")

    f_quality = read_quality_table(
        f_table,
        quality_quantile="25%"
    )

    trunc_f = estimate_trunc_len(
        f_quality,
        quality_threshold=args.quality_threshold,
        window=args.window,
    )

    trunc_r = 0

    if r_table is not None:

        log(f"INFO: Reverse table: {r_table}")

        r_quality = read_quality_table(
            r_table,
            quality_quantile="25%"
        )

        trunc_r = estimate_trunc_len(
            r_quality,
            quality_threshold=args.quality_threshold,
            window=args.window,
        )

    retained = trunc_f + trunc_r

    estimated_overlap = (
        retained - args.amplicon_length
        if trunc_r > 0
        else None
    )

    passes_overlap = (
        estimated_overlap >= args.min_overlap
        if estimated_overlap is not None
        else None
    )

    result = {
        "trunc_len_f": trunc_f,
        "trunc_len_r": trunc_r,
        "estimated_overlap": estimated_overlap,
        "passes_overlap": passes_overlap,
    }

    if args.output_format == "json":

        print(json.dumps(result, indent=2))

    else:

        print(f"TRUNC_LEN_F={trunc_f}")

        if trunc_r > 0:
            print(f"TRUNC_LEN_R={trunc_r}")

    if passes_overlap is False:

        log(
            "WARNING: Estimated overlap below minimum threshold. "
            "Paired-end merging may fail."
        )


if __name__ == "__main__":
    main()
