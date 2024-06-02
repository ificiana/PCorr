import pandas as pd


def process_file(file_path: str):
    file_extension = file_path.split(".")[-1].lower()
    if file_extension == "csv":
        df = pd.read_csv(file_path)
    elif file_extension in ["xls", "xlsx"]:
        df = pd.read_excel(file_path)
    else:
        raise ValueError(
            "Unsupported file type. Only CSV and Excel files are supported."
        )
    return df


def check_numeric(value):
    try:
        x = float(value)
        return True, x
    except ValueError:
        return False


def pre_process(df, col1, col2, mode="omit"):
    """
    Pre-process a DataFrame based on the specified mode and column names.

    Parameters:
        df (DataFrame): The input DataFrame.
        col1 (str): Name of the first column.
        col2 (str): Name of the second column.
        mode (str): Pre-processing mode ('zero' or 'omit').

    Returns:
        DataFrame: The pre-processed DataFrame with only col1 and col2.
    """

    col1 = df[col1]
    col2 = df[col2]

    res1 = []
    res2 = []

    for i, j in zip(col1, col2):
        num1 = check_numeric(i)
        num2 = check_numeric(j)
        if num1 and num2:
            res1.append(num1[1])
            res2.append(num2[1])
        else:
            if mode == "omit":
                continue
            elif mode == "zero":
                if num1:
                    res1.append(num1[1])
                elif num2:
                    res2.append(num2[1])

    return pd.DataFrame(data={col1.name: res1, col2.name: res2})
