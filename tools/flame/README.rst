Toolset to generate flamegraphs from a running emulator. Based on info extracted from xa-listing's output.

Generating flame graph
======================

Run ``mesen_gather_perf.lua`` in mesen::

	time mono Mesen.exe --testrunner tilt_\(E\).nes perf.lua

It will output performance data in ``/tmp/nes.perf``

Get flamegraph tool from ``https://github.com/brendangregg/FlameGraph``

Generate the flamegraph::

	cat /tmp/nes.perf | ./flamegraph.pl > /tmp/flame.svg

xa-listing output format
========================

File name::

	\n%s\n\n

Listing line::

	lineno      segment     address        data                          label           source
	([0-9 ]{5}) ([?ATBDUZ]):([0-9a-f]{4})  (([0-9a-f]{2} )*(\.\.\.)?)( +)([a-z0-9_]*)( +)(.*)
	0           6           8              14                            39
