# Copyright (c) 2023 Arkaprabha Sinha Roy (GitHub: "ificiana")
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from typing import Union

import numpy as np
import pandas as pd
from scipy.stats import linregress


def calculate_x_rank(x: pd.Series, ties: bool = True, seed: int = None) -> np.ndarray:
    """
    Calculate the rank of elements in a pandas Series 'x'.
    Parameters:
    - x (pd.Series): Input data for which ranks are calculated.
    - ties (bool): If True, handle tied ranks randomly. Default is True.
    - seed (int): Seed for reproducibility when handling ties. Default is None.
    Returns:
    - np.ndarray: Array of indices representing the sorted ranks of 'x'.
    """
    if ties:
        _random_state = seed if seed is not None else None
        rank_x = (
            x.sample(frac=1, random_state=_random_state)
            .rank(method="first")
            .reindex_like(x)
        )
    else:
        rank_x = x.rank().values
    return np.argsort(rank_x)


def one_kth(x: float, k: float) -> float:
    """
    Calculate the kth root of x.
    Parameters:
    - x (float): Input value.
    - k (float): Exponent for the root calculation.
    Returns:
    - float: Result of the kth root of x.
    """
    try:
        return float(x) ** float(1 / k)
    except OverflowError:
        return np.inf


def calculate_gamma(
    x: list[int],
    y: list[int],
    ties: bool = True,
    seed: int = None,
    debug: bool = False,
    simple: bool = True,
) -> Union[float, tuple[float, float, float]]:
    """
    Calculate gamma.
    Parameters:
    - x (list[int]): List of values for the first variable.
    - y (list[int]): List of values for the second variable.
    - ties (bool): If True, handle tied ranks in calculations. Default is True.
    - seed (int): Seed for reproducibility when handling ties. Default is None.
    - debug (bool): If True, print intermediate values during calculation. Default is False.
    - simple (bool): If True, return only the value of gamma. Default is True.
    Returns:
    - Union[float, tuple[float, float, float]]: Depending on 'simple', returns either:
        - The gamma value (float), or
        - A tuple containing xi, R-squared, and gamma (floats).
    """
    assert len(x) == len(y), "Both vectors must be of the same length"
    n = len(x)

    x = pd.Series(x) - min(x) + 1
    y = pd.Series(y) - min(y) + 1

    y_rank = y.rank(method="max")[calculate_x_rank(x, ties, seed)] / n
    numerator = np.abs(np.diff(y_rank)).sum() / (2 * n)

    inv_rank = y.rank(method="max", ascending=False).values / n
    denominator = np.mean(inv_rank * (1 - inv_rank)) if ties else n * (n * n - 1) / 3
    xi = 1 - numerator / denominator

    log_x = np.log(x)
    log_y = np.log(y)

    slope, intercept, r_value, p_value, std_err = linregress(log_x, log_y)
    k = slope
    a = np.exp(intercept)

    one_kth_values = pd.Series(one_kth(v, k) for v in y_rank)
    numerator = (one_kth_values.diff().abs()).sum() / (2 * n)
    denominator *= one_kth(a, k)

    try:
        gamma = 1 - float(numerator) / float(denominator)
    except ZeroDivisionError:
        gamma = -np.inf

    if debug:
        print(
            f"""\
Calculated intermediate values:
    xi: {xi}
    a: {a}
    k: {k}
    gamma: {gamma}
Measures:
[{xi}, {r_value ** 2}, {gamma}]
""",
            flush=True,
        )

    return gamma if simple else xi, r_value**2, gamma


if __name__ == "__main__":
    import time

    NUMBER = 1
    start = time.time()
    for _ in range(NUMBER):
        calculate_gamma(
            [1, 2, 5, 4, 45, 7, 7, -8, 70],
            [0, 1, 1, 4, 5, 6, 7, -89, 50],
            seed=None,
            debug=True,
        )
    print(f"Average execution time: {(time.time() - start) / NUMBER:.6f} seconds")
