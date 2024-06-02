# PCorr

P-Corr is a scientific application designed to process data files, calculate correlation coefficients, and perform power law validation between two columns of data. This tool is particularly useful for researchers and scientists who need to analyze and interpret relationships within their datasets.

Authored by [Arkaprabha Sinha Roy](https://www.linkedin.com/in/arkaprabha-sinha-roy/)
([@ificiana](https://github.com/ificiana/)) with generous help and feedback from
[Farhan Jawaid](https://www.linkedin.com/in/farhan-jawaid-aaa0321ab/),
[Manan Roy Choudhury](https://www.linkedin.com/in/manan-roy-choudhury-2b2093208/)
([view publications](https://www.researchgate.net/profile/Manan-Roy-Choudhury)),
and [Raghunath Sinha](https://www.linkedin.com/in/raghunath-sinha-518870228);
Under the guidance of [Dr. Krishan Kundu](https://www.researchgate.net/profile/Krishan-Kundu).

PROJ-CS781, PROJ-CS881 :: [Department of Computer Science & Engineering](https://www.gcetts.ac.in/departments/cse) ::
[Govt. College of Engineering and Textile Technology, Serampore](https://www.gcetts.ac.in/)

## Installing

1. Make sure poetry is installed with `poetry --version`
   - If not, install it from [https://python-poetry.org](https://python-poetry.org/docs/#installing-with-the-official-installer)
2. Requires Python 3.12.
3. Clone this repository:
   - `git clone https://github.com/ificiana/PCorr.git && cd PCorr`
4. Run `poetry install`
5. Run `poetry run gui`

## Structure

```t
PCorr
├── app.py                                      # run app
├── pcorr                                       # src
│   ├── gamma.py                                # calculate gamma, (c) Apache 2.0
│   ├── gui
│   │   ├── main.py                             # run app, main entrypoint
│   │   ├── ui                                  # QML files
│   │   │   ├── about.qml                       # about the app page
│   │   │   ├── headers.qml                     # column selecting page
│   │   │   ├── main.qml                        # landing page
│   │   │   ├── preview.qml                     # data preview page
│   │   │   └── result.qml                      # results viewing page
│   │   ├── __init__.py
│   ├── process_file.py                         # process csv files
│   ├── __init__.py
├── poetry.lock                                 # poetry lock
├── pyproject.toml                              # poetry setup
├── README.md
└── LICENSE                                     # LGPL
```

### Calculating Gamma

```ts
FUNCTION calculate_x_rank(x: pd.Series, ties: BOOLEAN = True, seed: INTEGER = None) RETURNS np.ndarray
    IF ties IS True THEN
        _random_state = seed IF seed IS NOT None ELSE None
        rank_x = RANDOM_SAMPLE(x, frac=1, random_state=_random_state)
        rank_x = RANK(rank_x, method="first")
        rank_x = REINDEX_LIKE(rank_x, x)
    ELSE
        rank_x = RANK(x).values
    ENDIF
    RETURN ARGSORT(rank_x)
END FUNCTION

FUNCTION one_kth(x: FLOAT, k: FLOAT) RETURNS FLOAT
    TRY
        RETURN x ^ (1 / k)
    EXCEPT OverflowError
        RETURN np.inf
    END TRY
END FUNCTION

FUNCTION calculate_gamma(
    x: LIST[INTEGER],
    y: LIST[INTEGER],
    ties: BOOLEAN = True,
    seed: INTEGER = None,
    debug: BOOLEAN = False,
    simple: BOOLEAN = True
) RETURNS UNION[FLOAT, TUPLE[FLOAT, FLOAT, FLOAT]]
    ASSERT LENGTH(x) == LENGTH(y)
    n = LENGTH(x)

    x = x - MIN(x) + 1
    y = y - MIN(y) + 1

    y_rank = RANK(y, method="max")[calculate_x_rank(x, ties, seed)] / n
    numerator = SUM(ABS(DIFF(y_rank))) / (2 * n)

    inv_rank = RANK(y, method="max", ascending=False).values / n
    denominator = MEAN(inv_rank * (1 - inv_rank)) IF ties ELSE n * (n^2 - 1) / 3
    xi = 1 - numerator / denominator

    log_x = LOG(x)
    log_y = LOG(y)

    slope, intercept, r_value, p_value, std_err = LINREGRESS(log_x, log_y)
    k = slope
    a = EXP(intercept)

    one_kth_values = SERIES(one_kth(v, k) FOR v IN y_rank)
    numerator = SUM(ABS(DIFF(one_kth_values))) / (2 * n)
    denominator *= one_kth(a, k)

    TRY
        gamma = 1 - numerator / denominator
    EXCEPT ZeroDivisionError
        gamma = -np.inf
    END TRY

    IF debug THEN
        PRINT "Calculated intermediate values:"
        PRINT "    xi:", xi
        PRINT "    a:", a
        PRINT "    k:", k
        PRINT "    gamma:", gamma
        PRINT "Measures:"
        PRINT "[", xi, ",", r_value^2, ",", gamma, "]"
    ENDIF

    RETURN gamma IF simple ELSE (xi, r_value^2, gamma)
END FUNCTION
```
