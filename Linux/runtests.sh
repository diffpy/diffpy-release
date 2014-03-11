#!/bin/sh

echo "# Testing diffpy.Structure:"
python -m diffpy.Structure.tests.run
echo

echo "# Testing diffpy.utils:"
python -m diffpy.utils.tests.run
echo

echo "# Testing diffpy.srreal:"
python -m diffpy.srreal.tests.run
echo

echo "# Testing pyobjcryst:"
python -m pyobjcryst.tests.run
echo

echo "# Testing diffpy.srfit:"
python -m diffpy.srfit.tests.run
