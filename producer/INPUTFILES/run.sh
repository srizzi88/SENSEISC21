#!/bin/bash

mpirun -n 2 ./lammpsDriver ./INPUTFILES/in.lj -n 50 -sensei ./INPUTFILES/adioswrite.xml

