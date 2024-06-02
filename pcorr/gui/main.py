import argparse
import os
import sys

import numpy as np
import scipy
from PySide6.QtCore import (
    Property,
    QObject,
    Signal,
    Slot,
    qInstallMessageHandler,
)
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from pyside6_utils.models import PandasTableModel

import pcorr.process_file as pf
from pcorr.gamma import calculate_gamma

parser = argparse.ArgumentParser(description="Set debug mode.")
parser.add_argument(
    "--debug", dest="debug", action="store_true", help="Enable debug mode"
)
parser.add_argument(
    "--no-debug", dest="debug", action="store_false", help="Disable debug mode"
)
parser.set_defaults(debug=False)

args = parser.parse_args()
DEBUG = args.debug


def message_handler(_t, _c, m):
    if DEBUG:
        print(m)


class Backend(QObject):
    fileProcessed = Signal()
    resultGenerated = Signal()
    dataProcessed = Signal()

    def __init__(self):
        super().__init__()
        self._selected_df = None
        self._headers = None
        self._col1 = None
        self._col2 = None
        self._prepped_df = None
        self._model = None
        self._mad = None
        self._result = None

    @Slot(int)
    def initiate(self, _i):
        if _i == 0:
            self._selected_df = None
            self._headers = None
            self._col1 = None
            self._col2 = None
        self._prepped_df = None
        self._model = None
        self._mad = None
        self._result = None
        engine.rootContext().setContextProperty("pyModel", self._model)

    @Slot(int)
    def calculate_result(self, _i):
        self._result = calculate_gamma(
            self._prepped_df[self._col1],
            self._prepped_df[self._col2],
            debug=True,
        )

    @Slot(str)
    def processFile(self, file_path):
        self._selected_df = pf.process_file(file_path)
        self._headers = (
            list(self._selected_df.columns) if self._selected_df is not None else []
        )
        self.fileProcessed.emit()

    @Slot(str, str)
    def selectHeaders(self, col1, col2):
        _df = pf.pre_process(self._selected_df, col1, col2)
        self._col1, self._col2 = col1, col2
        self._prepped_df = _df
        self._model = PandasTableModel(self._prepped_df)
        engine.rootContext().setContextProperty("pyModel", self._model)
        self._mad = scipy.stats.median_abs_deviation(
            self._prepped_df[self._col2], scale=np.median(self._prepped_df[self._col2])
        )
        self.dataProcessed.emit()

    def getHeaders(self):
        return self._headers

    def getSelectedHeaders(self):
        return self._col1, self._col2

    def getMAD(self):
        return f"{self._mad:.3f}"

    def getResult(self):
        return f"{self._result[2]}"

    headers = Property(list, getHeaders)
    selectedHeaders = Property(list, getSelectedHeaders)
    madValue = Property(str, getMAD)
    result = Property(str, getResult)


app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
qInstallMessageHandler(message_handler)
HERE = os.path.dirname(os.path.abspath(__file__))
QML_ENTRY = os.path.join(HERE, "ui", "main.qml")


def run_app():
    global engine
    backend = Backend()
    engine.rootContext().setContextProperty("py", backend)
    engine.load(QML_ENTRY)
    if not engine.rootObjects():
        sys.exit(-1)
    exit_code = app.exec()
    del engine
    sys.exit(exit_code)


if __name__ == "__main__":
    run_app()
