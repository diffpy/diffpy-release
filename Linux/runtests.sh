#!/bin/sh

python -m diffpy.pdfgui.tests.rundeps
python -m diffpy.srreal.tests.run
python -m diffpy.srfit.tests.run
python -m diffpy.pdfgetx.tests.run
