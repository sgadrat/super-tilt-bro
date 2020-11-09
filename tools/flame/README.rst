Toolset to generate flamegraphs from a running emulator. Based on info extracted from xa-listing's output.

Generating flame graph
======================

Raw perf report
---------------

Run ``mesen_gather_perf.lua`` in Mesen::

	mono Mesen.exe --testrunner tilt_\(E\).nes mesen_gather_perf.lua

It will output performance data in ``/tmp/nes.perf``

Translate adresses to routine name
----------------------------------

Optional, translate routines addresses to routine names::

	# /tmp/dbg.txt is the output of compiling with xa-listing
	cat /tmp/dbg.txt | PYTHONPATH=$PYTHONPATH:.. ./routines_addresses.py | ./address_translate.py > /tmp/nes-named.perf

Construct the flamegraph
------------------------

Get flamegraph tool from ``https://github.com/brendangregg/FlameGraph``

Generate the flamegraph::

	cat /tmp/nes.perf | ./flamegraph.pl > /tmp/flame.svg

Annotate source code
====================

With raw performance report, and xa-listing's output you can generate source code annotated with the number of cycle per line::

	PYTHONPATH=$PYTHONPATH:.. ./annotate.py /tmp/nes.perf /tmp/dbg.txt > /tmp/nes.annotate.md

xa-listing output format
========================

File name::

	\n%s\n\n

Listing line::

	lineno      segment     address        data                          label           source
	([0-9 ]{5}) ([?ATBDUZ]):([0-9a-f]{4})  (([0-9a-f]{2} )*(\.\.\.)?)( +)([a-z0-9_]*)( +)(.*)
	0           6           8              14                            39
