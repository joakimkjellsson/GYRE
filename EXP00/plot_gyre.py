import numpy as np
import matplotlib.pyplot as plt
import xarray as xr

files = ['../EXP00_R4/GYRE_5d_00010101_00401231']

ufiles = []
vfiles = []
tfiles = []
ffiles = []

for i in range(0,len(files)):
   ffiles.append( xr.open_mfdataset('%sgrid_F.nc' % (files[i],),combine='by_coords') )
   tfiles.append( xr.open_mfdataset('%s_grid_T.nc' % (files[i],),combine='by_coords') )

for i in range(0,len(files)):
   print(ffiles[i])
   ffile = ffiles[i]
   tfile = tfiles[i]
   
   # Plot snapshot of last
   fig_a, ax_a = plt.subplots(1,1)
   cf = ax_a.tricontourf(ffile['nav_lon'].values.flatten(), ffile['nav_lat'].values.flatten(), ffile['relvor'][-1,0,:,:].values.flatten())
   plt.colorbar(cf,ax=ax_a)
   
   fig_b, ax_b = plt.subplots(1,1)
   cf = ax_b.tricontourf(tfile['nav_lon'].values.flatten(), tfile['nav_lat'].values.flatten(), tfile['ssh'][-1,:,:].values.flatten())
   plt.colorbar(cf,ax=ax_b)
   
plt.show()
