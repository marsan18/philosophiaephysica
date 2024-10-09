


def autotrack(startframe): #start must be a string that indicates the name of the first frame of each video (all videos should have the same first frame name) including the file extension
	#print 'Testing autotrack'
	import os, shutil

	os.environ['TCL_LIBRARY'] = 'C:\Program Files\CISMM/video_spot_tracker_v08.01.03_extra_output/tcl8.3'
	os.environ['TK_LIBRARY'] = 'C:\Program Files\CISMM/video_spot_tracker_v08.01_.03extra_output/tk8.3'

	rootdir = os.getcwd()
	start,filetype = os.path.splitext(startframe)
	
	autofindframename = 'autofind_frame'+filetype
	startframename = start+filetype
	print('Searching for files with name %s' % startframename)
	#findlist is the list of first video frames found in the current directory and its subdirectories
	findlist = []
	#files = []
	for dirpath, dirnames, filenames in os.walk(rootdir):
		for filename in [f for f in filenames if f.endswith(start+filetype)]:
			findlist.append(os.path.join(dirpath,filename))
		#for filename in [c for c in filenames if c.endswith('.cfg')]:
		#	[root,ext] = os.path.splitext(filename)
		#	if ext == '.cfg':
		#		files.append(os.path.join(dirpath,filename))
	print('Found all start frames:')
	print('\n' .join(findlist))
	#print('Found these config files:')
	#print('\n' .join(files))

	widgets_tcl = 'C:\Program Files\CISMM/video_spot_tracker_v08.01.03_extra_output/russ_widgets.tcl'
	vst_tcl = 'C:\Program Files\CISMM/video_spot_tracker_v08.01.03_extra_output/video_spot_tracker.tcl'
	new_widgets = os.path.join(rootdir,'russ_widgets.tcl')
	new_vsttcl = os.path.join(rootdir,'video_spot_tracker.tcl')
	shutil.copy(widgets_tcl,rootdir)
	shutil.copy(vst_tcl,rootdir)
	print('Moved tcl files.')

	for i in findlist: #For each video found
		#Create autofind frame
		thisvideodir = os.path.dirname(i)
		source = os.path.join(thisvideodir,startframename)
		dest = os.path.join(thisvideodir,autofindframename)
		shutil.copy(source,dest)
		
		#These will be inputs to Run_VST
		abs_autoframename = os.path.join(rootdir,thisvideodir,autofindframename) #where to find auto find frame for Run_VST?
		abs_autoframename = '"'+abs_autoframename+'"'
		abs_startframename = os.path.join(rootdir,thisvideodir,startframename) #where to find start frame for Run VST?
		abs_startframename = '"'+abs_startframename+'"'
		logpath = os.path.join(rootdir,thisvideodir) #where and name for saving the tracking data
		current_directoryname = os.path.split(thisvideodir)[1]
		logname = logpath+'\\'+current_directoryname

		#Find cfg files in this video's directory
		states = []
		for dirpath,dirnames,filenames in os.walk(thisvideodir):
			for filename in [c for c in filenames if c.endswith('.cfg')]:
				states.append(os.path.join(dirpath,filename))
		if len(states) < 1:
			print('No configuration files found for this video.')
		else: 
			print('Found these state files for %s :' % thisvideodir)
			print('\n' .join(states))

			for cfg in states:
				Run_VST(logname,abs_startframename,abs_autoframename,cfg)

	os.remove(new_widgets)
	os.remove(new_vsttcl)
	print('Removed tcl files.')
	os.chdir(rootdir)
	print('Done tracking with all states.')


def Run_VST(logname,startframename,autofindframe,cfg): #will take inputs autofindframe,startframe,logname
	import os, shutil, re, subprocess

	wd = os.getcwd()
	extension = '.vrpn'
	#vst_path = '"C:\\Program Files\\CISMM\\video_spot_tracker_v08.01_extra_output\\video_spot_tracker_nogui.exe"'
	vst_path = '"C:\\Program Files\\CISMM\\video_spot_tracker_v08.01.03_extra_output\\video_spot_tracker.exe"'
	#state = 'C:\\Users\\phoebelee\\Desktop\\testconfig.cfg'
	#print state

	cfgname = os.path.split(cfg)[1]
	temptraj = '"'+logname + '_tmp"'
	trajoutfile = '"'+logname+'_'+cfgname+'"'

	#needs to go through several config files at a time

	cfgfile = open(cfg)
	parameters = cfgfile.readlines()
	cfgfile.close()
	#print parameters
	for p in parameters:
		if p.startswith('set radius'):
			radius_line = p
	r = re.findall('\d+',radius_line)
	r = int(r[0])
	print('Tracker Radius = ' + str(r))

	#autofind_vst = vst_path+' -nogui -enable_internal_values -lost_all_colliding_trackers -load_state "'+cfg+'" -tracker 0 0 '+str(r)+' -outfile '+temptraj+' '+autofindframe
	#track =        vst_path+' -nogui -enable_internal_values -lost_all_colliding_trackers -load_state "'+cfg+'" -maintain_fluorescent_beads 0 -log_video 300 -tracker 0 0 '+str(r)+' -continue_from '+temptraj+'.csv -outfile '+trajoutfile+' '+startframename

	autofind_vst = vst_path+'  -enable_internal_values  -load_state "'+cfg+'" -tracker 0 0 '+str(r)+' -outfile '+temptraj+' '+autofindframe
	track =        vst_path+'  -enable_internal_values  -load_state "'+cfg+'" -tracker 0 0 '+str(r)+' -continue_from '+temptraj+'.csv -outfile '+trajoutfile+' '+startframename

	subprocess.call(autofind_vst)

		
	subprocess.call(track)

	os.remove(logname+'_tmp.csv')
	os.remove(logname+'_tmp.vrpn')
	print('Removed temp files.')
	#remove temporary autofind files (temptraj)

	print('Done.')



def create_cfg(project,params_to_set_file):
	#params_to_set_file can be tuples specifying [parameter,value] or existing file path and name
	import os
	import numpy as np

	if not params_to_set_file: #if empty input is given
		print('No parameters specified. Creating default configuration.')
		presets = []

	elif (not isinstance(params_to_set_file[0][1],(int,float))): 
		print(not isinstance(params_to_set_file,(int,float)))
		#there is an input and it is a text file
		inparams = open(params_to_set_file,'r')
		in_lines = inparams.readlines()
		inparams.close()
		length = len(in_lines)
		presets = []

		for line in in_lines:
			wout_set = line[4:]
			print(wout_set)
			wout_nums = ''.join([i for i in wout_set if not i.isdigit() and not i=='.' and not i==' '])
			print([wout_nums[0:-1]+'.'])
			only_num = [n for n in wout_set if n.isdigit() or n=='.']
			only_num = ''.join(only_num)
			print(only_num)
			presets.append([wout_nums[0:-1], only_num])

		print('These parameters specified:')
		for param in presets:
			print(param)

	elif isinstance(params_to_set_file[0][1],(int,float)): #there is an input and it is numeric
		presets = params_to_set_file

		print('These parameters specified:')
		for param in presets:
			print(param)


	default_cfg(project,presets)




def default_cfg(project,presets):

	import os 
	import numpy as np

	if project == 'lai': # Note: If presets includes a parameter specified by "Lai", the preset will be overwritten by the "Lai" default
		print('Adding default parameters for Lai Lab tracking to presets.')
		presets.append(['intensity_lost_tracking_sensitivity',0.05])
		presets.append(['dead_zone_around_border',5])
		presets.append(['dead_zone_around_trackers',5])
		presets.append(['radius',10])
		presets.append(['maintain_fluorescent_beads',400])
		presets.append(['lost_behavior',1])
		presets.append(['optimize',1])
		presets.append(['check_bead_count_interval',1])
		presets.append(['blur_lost_and_found',0])
		presets.append(['center_surround',0])

	rootdir=os.getcwd()	
	fileparts=os.path.split(rootdir)
	cfgname = rootdir+'\\'+fileparts[1] +'.cfg'
	cfgfile = open(cfgname,'a')
	print('Writing the following to cfg file called '+cfgname+':')

	for param in presets:
		p = 'set ' + param[0] + ' ' + str(param[1]) 
		print(p)
		cfgfile.write(p + '\n')

	cfgfile.close()

	print('Created configuration file for each video.')

def get_frames(file,directory):
	import os,shutil,PIL
	from PIL import Image
	
	rtname=os.path.basename(file) 
	rtname=rtname.split('.')
	newfilepath=os.path.join(directory,rtname[0])  #naming and creation of new folder for individual videos
	os.makedirs(newfilepath)
	shutil.move(file,newfilepath)
	os.chdir(newfilepath)
	
	im = Image.open(file)
	imcount=im.n_frames
	
	for i in range(0,imcount): ##individual frames saved
		im.seek(i)
		im.save('frame_%04i.tif' %(i,))

	print('done with frames')

def roisin_thresh(adj):
	import os,numpy 
	import matplotlib.pyplot as plt
	
	im=plt.imread('frame_0000.tif')
	if im.max()>256:
		bit=16
		pixelCount,bins=numpy.histogram(im,bins=numpy.arange(0,65536,13.1))
	else:
		bit=8
		pixelCount,bins= numpy.histogram(im,range(257))

	max_peak=numpy.max(pixelCount)
	peak_coord=pixelCount.argmax()
	topPoint=[peak_coord, max_peak]
	ind_nonZero=numpy.nonzero(pixelCount)[-1]
	last_zeroBin=ind_nonZero[-1]
	bottomPoint=[last_zeroBin,pixelCount[last_zeroBin]]
	best_idx=-1
	max_dist=-1
	for x0 in range(peak_coord, last_zeroBin):
		y0=pixelCount[x0]
		a=[topPoint[0]-bottomPoint[0],topPoint[1]-bottomPoint[1]]
		b=[x0-bottomPoint[0],y0-bottomPoint[1]]
		cross_ab = a[0]*b[1]-b[0]*a[1]
		d=numpy.linalg.norm(cross_ab)/numpy.linalg.norm(a)
		if d>max_dist:
			best_idx=x0
			max_dist=d
	if bit==8:
		ints_cut=best_idx
		level=ints_cut/256
	else:
		ints_cut=best_idx*13.1
		level=ints_cut/65537
	maxPixel=numpy.max(im)
	minPixel=numpy.min(im)
	threshold=(ints_cut)/((maxPixel-minPixel)+minPixel)
	if bit ==16:
		flat_length=maxPixel/13.1-best_idx
		new_idx=best_idx+flat_length*adj
		adj_threshold=(new_idx*13.1)/((maxPixel-minPixel)+minPixel)
	else:
		flat_length=maxPixel-best_idx
		new_idx=best_idx+flat_length*adj
		adj_threshold[len(adj_threshold)]=(new_idx)/((maxPixel-minPixel)+minPixel)
	return adj_threshold

def removeframes():
	import os
	current=os.getcwd()
	for root,dirs,files in os.walk(current):
		for file in files:
			if file.startswith('frame_') or file.starstwith('auto'):
				os.remove(file)
			

def main():
	import os
	directory=os.getcwd()
	for root, dirs, files in os.walk(directory):
		for file in files:
			if file.endswith('.tif'):
				get_frames(file,directory)
				threshold=roisin_thresh(.1)
				create_cfg('lai',[('fluorescent_spot_threshold',threshold)])
				autotrack('frame_0000.tif')
				#removeframes();
				os.chdir(directory)
				
