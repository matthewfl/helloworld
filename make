#!/usr/bin/env python2

import sys
sys.path.insert(0, 'deps/fabricate/')

import glob
import subprocess
import os
from fabricate import *

TARGET = 'hello-world'

UNIT_TARGET = 'build/unit_tests'

CXX_FLAGS = (
    '-I ./deps/ '
    '-ggdb '
    '-O0 '
    '-fopenmp '
)
CXX_FLAGS_UNIT = (
    '-I ./deps/catch/ '
    '-I ./src/ '
)
LIBS = (
    '-fopenmp '
    # '-ljemalloc'
)
LD_FLAGS = ''
CXX='g++'
LD='g++'

def build():
    compile()
    link()

def mic():
    global CXX, CXX_FLAGS, LD
    CXX_FLAGS += '-wd1478 '  # using dep std::smart pointer
    CXX = 'icpc'
    LD = 'icpc'

def release():
    global CXX_FLAGS
    CXX_FLAGS = CXX_FLAGS.replace('-O0', '-O3')
    build()

def clean():
    autoclean()

def run():
    build()
    Shell('./' + TARGET)

def debug():
    build()
    Shell('gdb ./{TARGET} --eval-command=run'.format(
        TARGET=TARGET
    ))

def link():
    objs = ' '.join(filter(lambda x: 'unit_' not in x, glob.glob('build/*.o')))
    Run('{CXX} {LD_FLAGS} -o {TARGET} {objs} {LIBS}'.format(
        **dict(globals(), **locals())
    ))
    after()

def compile():
    for f in glob.glob('src/*.cc'):
        Run('{CXX} {} -c {} -o {}'.format(
            CXX_FLAGS,
            f,
            f.replace('src', 'build').replace('.cc', '.o'),
            CXX=CXX
        ))
    after()

def unit_compile():
    for f in glob.glob('unit_tests/*.cc'):
        Run('{CXX} {} -c {} -o {}'.format(
            CXX_FLAGS + CXX_FLAGS_UNIT,
            f,
            f.replace('unit_tests/', 'build/unit_').replace('.cc', '.o'),
            CXX=CXX,
        ))

def unit_link():
    objs = ' '.join(filter(lambda x: '/main.o' not in x, glob.glob('build/*.o')))
    Run('{CXX} {LD_FLAGS} -o {UNIT_TARGET} {objs} {LIBS}'.format(
        **dict(globals(), **locals())
    ))
    after()

def unit():
    unit_compile()
    compile()
    unit_link()
    Shell('./' + UNIT_TARGET)


if __name__ == '__main__':
    main(parallel_ok=True)#, jobs=4)
