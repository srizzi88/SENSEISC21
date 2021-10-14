#!/bin/bash

mpirun -n 2 ./SENSEIEndPoint -a ./INPUTFILES/vtk.xml -t ./INPUTFILES/adiosread.xml
