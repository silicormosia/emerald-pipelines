import matplotlib.pyplot as PLT
import netCDF4 as NC
import sys


# 1. read the data to plot
filename = sys.argv[1]
dset = NC.Dataset(filename, "r")
lats = dset.variables["lat"][:]
lons = dset.variables["lon"][:]

# 2. plot the data
print("Plotting the annual means from", filename)
DF_VAR_NAMES = ["GPP", "ET", "SIF740"]
fig = PLT.figure(dpi=300, figsize=(8.5,12))
for i in range(1,4):
    ax = fig.add_subplot(3,1,i)
    data = dset.variables[DF_VAR_NAMES[i-1]][:]
    cmap = ax.pcolormesh(lons, lats, data, shading="auto")
    ax.set_aspect("equal")
    fig.colorbar(cmap, ax=ax, fraction=0.025)
    ax.set_title("mean " + DF_VAR_NAMES[i-1], loc="left")

# save the figure
fig.set_tight_layout(True)
fig.savefig(filename[0:len(filename)-2] + "jpg", bbox_inches="tight")
