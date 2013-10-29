#!/bin/sh

# python -m diffpy.pdfgui.tests.rundeps
python -m diffpy.Structure.tests.run
python -m diffpy.srreal.tests.run
python -m diffpy.srfit.tests.run

# FIXME ... add pyobjcryst unit tests.
