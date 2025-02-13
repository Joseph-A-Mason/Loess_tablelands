# -*- coding: utf-8 -*-
"""
Created on Tue Apr 30 21:23:18 2019

@author: mason
"""
#Comprehensive script for loess table model used for results in
#loess tableland paper
#This version is for scenarios with initiation from bedrock surfaces
#(Bedrock-Drain and Bedrock-Depressions)

from landlab.components import LinearDiffuser
from landlab.components import FlowAccumulator
from landlab.components import ErosionDeposition
from landlab.plot import imshow_grid
from landlab.io import read_esri_ascii
from landlab.io import write_esri_ascii
from landlab import RasterModelGrid
from matplotlib.pyplot import figure
import numpy as np
import os


#Import DEM of Ogallala surface from ESRI ASCII file
(mg, z) = read_esri_ascii('___/og_surf4.txt', name = 'topographic__elevation')

os.chdir('')
#Set grid boundary conditions
for edge in (mg.nodes_at_left_edge, mg.nodes_at_right_edge,
             mg.nodes_at_bottom_edge):
    mg.status_at_node[edge] = mg.BC_NODE_IS_CLOSED
for edge in (mg.nodes_at_top_edge):
    mg.status_at_node[edge] = mg.BC_NODE_IS_FIXED_VALUE

nrows = 626
ncols = 626
dx = 10.0

#create erosion-deposition logging, uplift, and flow accumulation variables
prev_elev = mg.add_zeros('node', 'prev_elev')
t_erode_dep = mg.add_zeros('node', 't_erode_dep')
local_uplift = mg.add_zeros('node', 'local_uplift')

fr = FlowAccumulator(mg, flow_director= 'D8')

#Stage 1: Peoria Loess accumulation for 12000 years
#Erosion and deposition according to Davy and Lague
#Spatially uniform parameters
Ksp = 0.0012
Sp_crit = 0.001
erode = ErosionDeposition(mg, K=Ksp, v_s=0.001, m_sp=0.5, n_sp=1.0,
                          sp_crit=Sp_crit, F_f=0.0)
#linear diffusion
D=0.05
lin_diffuse = LinearDiffuser(mg, linear_diffusivity=D)
#uplift and timesteps
uplift_rate = 0.0025 #Used to represent 2 mm/yr loess deposition
total_t = 12000
dt = 0.2

#set number of steps and uplift per step
nt = int(total_t // dt) #number of loops
uplift_per_step = uplift_rate * dt

for i in range(nt):
    #ramp parameters in last 0.10 of this phase to Brady Soil interval values
    if i > 0.9*nt:
        Ksp=Ksp-(0.0006*(1/(0.10*nt)))
        D=D+(0.05*(1/(0.10*nt)))
        Sp_crit=Sp_crit+(0.001*(1/(0.10*nt)))
        uplift_rate=uplift_rate-(0.00225*(1/(0.10*nt)))
        uplift_per_step = uplift_rate * dt
    #for tallying erosion and deposition independent of loess deposition
    #sets previous elevation variable to current elevation
    mg.at_node['prev_elev'].fill(0)
    mg.at_node['prev_elev'] += mg.at_node['topographic__elevation']
    #erosion and sediment transport
    lin_diffuse.run_one_step(dt)
    fr.run_one_step()
    erode.run_one_step(dt)
    #subtract new elevation from previous elevation, add result to
    #erosion/deposition tally
    mg.at_node['prev_elev']-=mg.at_node['topographic__elevation']
    mg.at_node['t_erode_dep']+=mg.at_node['prev_elev']
    mg.at_node['topographic__elevation'][mg.core_nodes] += uplift_per_step
    if i % 1250 == 0:
        print('Completed loop %d' % i)
        print(Ksp, D, Sp_crit, uplift_rate, uplift_per_step)
        #output figures for evaluating model and animation
        figure('topography')
        name_str = './animation/{}map.png'.format((i/1250)+100)
        imshow_grid(mg, 'topographic__elevation', grid_units=['m','m'],
                    var_name='Elevation (m)', output=name_str)
        figure('erosion-deposition')
        name_str = './animation/{}erosion.png'.format(((i/1250)+100))
        imshow_grid(mg, 't_erode_dep', grid_units=['m','m'],
                    var_name='Erosion or Deposition (m/250 yr)',
                    output=name_str)
        #output dem and erosion grid
        elev_name_str = '{}elevation_Peoria.txt'.format(((i/1250)+100))
        write_esri_ascii(elev_name_str, mg, 'topographic__elevation')
        erosion_name_str = '{}erosion_Peoria.txt'.format(((i/1250)+100))
        write_esri_ascii(erosion_name_str, mg, 't_erode_dep')
        mg.at_node['t_erode_dep'].fill(0)

#Stage 2: Brady Soil formation and very slow accumulation for 4000 years
#Erosion and deposition according to Davy and Lague
#Spatially uniform parameters
#Lower by 0.5X K, 0.0002 threshold stream power
Ksp=0.0006
Sp_crit=0.002
erode = ErosionDeposition(mg, K = Ksp, v_s=0.001, m_sp=0.5, n_sp=1.0,
                          sp_crit=Sp_crit, F_f=0.0)
#linear diffusion, higher by 10X diffusivity
D=0.1
lin_diffuse = LinearDiffuser(mg, linear_diffusivity=D)
#uplift and timesteps
uplift_rate = 0.00025 #Used to represent 0.25 mm/yr loess deposition
total_t = 4000
dt = 0.2
#set timescale and uplift rate
nt = int(total_t // dt) #number of loops
uplift_per_step = uplift_rate * dt

for i in range(nt):
    if i > 0.75*nt:
        Ksp=Ksp+(0.0006*(1/(0.25*nt)))
        D=D-(0.05*(1/(0.25*nt)))
        Sp_crit=Sp_crit-(0.001*(1/(0.25*nt)))
        uplift_rate=uplift_rate+(0.00035*(1/(0.25*nt)))
        uplift_per_step = uplift_rate * dt
    #for tallying erosion and deposition independent of loess deposition
    #sets previous elevation variable to current elevation
    mg.at_node['prev_elev'].fill(0)
    mg.at_node['prev_elev'] += mg.at_node['topographic__elevation']
    #erosion and sediment transport
    lin_diffuse.run_one_step(dt)
    fr.run_one_step()
    erode.run_one_step(dt)
    #subtract new elevation from previous elevation, add result to
    #erosion/deposition tally
    mg.at_node['prev_elev']-=mg.at_node['topographic__elevation']
    mg.at_node['t_erode_dep']+=mg.at_node['prev_elev']
    mg.at_node['topographic__elevation'][mg.core_nodes] += uplift_per_step
    if i % 1250 == 0:
        print('Completed loop %d' % i)
        print(Ksp, D, Sp_crit, uplift_rate, uplift_per_step)
        #output figures for evaluating model and animation
        figure('topography')
        name_str = './animation/{}map.png'.format(((i+60000)/1250)+100)
        imshow_grid(mg, 'topographic__elevation', grid_units=['m','m'],
                    var_name='Elevation (m)', output=name_str)
        figure('erosion-deposition')
        name_str = './animation/{}erosion.png'.format(((i+60000)/1250)+100)
        imshow_grid(mg, 't_erode_dep', grid_units=['m','m'],
                    var_name='Erosion or Deposition (m/250 yr)',
                    output=name_str)
        #output dem and erosion grid
        elev_name_str = '{}elevation_Brady.txt'.format(((i+60000)/1250)+100)
        write_esri_ascii(elev_name_str, mg, 'topographic__elevation')
        erosion_name_str = '{}erosion_Brady.txt'.format(((i+60000)/1250)+100)
        write_esri_ascii(erosion_name_str, mg, 't_erode_dep')
        mg.at_node['t_erode_dep'].fill(0)

#Stage 3: Bignell Loess accumulation for 10000 years
#Slower accumulation than Peoria Loess but erosion parameters the same
#Erosion and deposition according to Davy and Lague
#Spatially uniform parameters
#High K, no threshold stream power
Ksp = 0.0012
Sp_crit = 0.001
erode = ErosionDeposition(mg, K=Ksp, v_s=0.001, m_sp=0.5, n_sp=1.0,
                          sp_crit=Sp_crit, F_f=0.0)
#linear diffusion
D=0.05
lin_diffuse = LinearDiffuser(mg, linear_diffusivity=D)
uplift_rate = 0.0006 #Used to represent 0.6 mm/yr loess accumulation
total_t = 10000
dt = 0.2

#set timescale and uplift rate
nt = int(total_t // dt) #number of loops
uplift_per_step = uplift_rate * dt

for i in range(nt):
    #for tallying erosion and deposition independent of loess deposition
    #sets previous elevation variable to current elevation
    mg.at_node['prev_elev'].fill(0)
    mg.at_node['prev_elev'] += mg.at_node['topographic__elevation']
    #erosion and sediment transport
    lin_diffuse.run_one_step(dt)
    fr.run_one_step()
    erode.run_one_step(dt)
    #subtract new elevation from previous elevation, add result to
    #erosion/deposition tally
    mg.at_node['prev_elev']-=mg.at_node['topographic__elevation']
    mg.at_node['t_erode_dep']+=mg.at_node['prev_elev']
    mg.at_node['topographic__elevation'][mg.core_nodes] += uplift_per_step
    if i % 1250 == 0:
        print('Completed loop %d' % i)
        print(Ksp, D, Sp_crit, uplift_rate, uplift_per_step)
        #output figures for evaluating model and animation
        figure('topography')
        name_str = './animation/{}map.png'.format(((i+80000)/1250)+100)
        imshow_grid(mg, 'topographic__elevation', grid_units=['m','m'],
                    var_name='Elevation (m)', output=name_str)
        figure('erosion-deposition')
        name_str = './animation/{}erosion.png'.format(((i+80000)/1250)+100)
        imshow_grid(mg, 't_erode_dep', grid_units=['m','m'],
                    var_name='Erosion or Deposition (m/250 yr)',
                    output=name_str)
        #output dem and erosion grid
        elev_name_str = '{}elevation_Bignell.txt'.format(((i+80000)/1250)+100)
        write_esri_ascii(elev_name_str, mg, 'topographic__elevation')
        erosion_name_str = '{}erosion_Bignell.txt'.format(((i+80000)/1250)+100)
        write_esri_ascii(erosion_name_str, mg, 't_erode_dep')
        mg.at_node['t_erode_dep'].fill(0)

#Run to save final DEM and maps
figure('topography')
name_str = './animation/{}map.png'.format(((i+130000)/1250)+100)
imshow_grid(mg, 'topographic__elevation', grid_units=['m','m'],
            var_name='Elevation (m)', output=name_str)
figure('erosion-deposition')
name_str = './animation/{}erosion.png'.format(((i+130000)/1250)+100)
imshow_grid(mg, 't_erode_dep', grid_units=['m','m'],
            var_name='Erosion or Deposition (m/250 yr)', output=name_str)
#output dem and erosion grid
elev_name_str = '{}elevation_Bignell.txt'.format(((i+130000)/1250)+100)
write_esri_ascii(elev_name_str, mg, 'topographic__elevation')
erosion_name_str = '{}erosion_Bignell.txt'.format(((i+130000)/1250)+100)
write_esri_ascii(erosion_name_str, mg, 't_erode_dep')
mg.at_node['t_erode_dep'].fill(0)