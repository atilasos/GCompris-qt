# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile the explicitly selected RCC inspector and export one resource tree."""
import json
import subprocess

def compile_exporter(source,binary):
 flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split()
 subprocess.run(['g++','-std=c++17','-fPIC',str(source),'-o',str(binary),*flags],check=True)

def export_resources(binary,resource,destination):
 rows=json.loads(subprocess.check_output([str(binary),str(resource),str(destination)]))
 if not isinstance(rows,list):raise ValueError('RCC exporter must return file records')
 return rows
