#!/usr/bin/env python3

import sys
import matplotlib.pyplot as plt
import numpy as np

if len(sys.argv) < 3:
  print("Usage:", sys.argv[0], " <outfig name> <input log> [...<input log>]")
  sys.exit()

outFig=sys.argv[1]+".png"

labels = []
for inlog in sys.argv[2:]:
  print(inlog)
  f = open(inlog,"r")
  opt = []
  for line in f:
    bw = float(line)
    opt.append(bw)
  plt.plot(opt)
  labels.append(inlog)

plt.legend(labels)
plt.xlabel('threads')
plt.ylabel('MB/s')
plt.title('STREAM Triad Bandwidth')
plt.grid(True)
plt.savefig(outFig)
plt.show()
