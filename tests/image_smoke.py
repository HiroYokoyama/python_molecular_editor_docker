"""Exercise the installed Linux package, native Qt libraries and 3D rendering."""

from importlib import metadata
from pathlib import Path
import subprocess
import sys

assert metadata.version("moleditpy") == sys.argv[1]
installed = {d.metadata["Name"].lower().replace("_", "-") for d in metadata.distributions()}
assert not installed.intersection({"moleditpy-linux", "pyqt6", "openbabel", "openbabel-wheel"})

from PySide6.QtCore import QLibraryInfo, QTimer
from PySide6.QtWidgets import QApplication

xcb = Path(QLibraryInfo.path(QLibraryInfo.LibraryPath.PluginsPath)) / "platforms" / "libqxcb.so"
dependencies = subprocess.check_output(["ldd", str(xcb)], text=True)
assert "not found" not in dependencies, dependencies

import pyvista as pv
from pyvistaqt import QtInteractor  # Verify QtPy selects the intended binding.
import qtpy
from rdkit import Chem
from moleditpy.ui.main_window import MainWindow

assert qtpy.API_NAME == "PySide6", qtpy.API_NAME
assert Chem.MolFromSmiles("CCO").GetNumAtoms() == 3

plotter = pv.Plotter(off_screen=True, window_size=(160, 120))
plotter.add_mesh(pv.Sphere())
pixels = plotter.screenshot(return_img=True)
assert pixels.shape[:2] == (120, 160)
assert pixels.std() > 0, "3D render produced an empty image"
plotter.close()

app = QApplication([])
window = MainWindow(safe_mode=True)
window.show()
errors = []


def check_window():
    try:
        assert window.isVisible(), "Main window did not become visible"
        assert window.view_3d_manager.plotter is not None, "3D view was not initialized"
        window.view_3d_manager.plotter.render()
        print("Main window, PySide6/xcb dependencies, RDKit and 3D rendering passed", flush=True)
    except Exception as exc:
        errors.append(exc)
    finally:
        window.close()
        app.quit()


QTimer.singleShot(1500, check_window)
app.exec()
assert not errors, errors
