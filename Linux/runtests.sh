#!/bin/sh -x

python -m diffpy.Structure.tests.run
python -m diffpy.utils.tests.run
python -m diffpy.srreal.tests.run
python -m pyobjcryst.tests.run
python -m diffpy.srfit.tests.run
