%% TrackMate in MATLAB example.
% We run a full analysis in MATLAB, calling the Java classes.
% More information here:
% https://imagej.net/plugins/trackmate/scripting/scripting
% https://imagej.net/plugins/trackmate/scripting/using-from-matlab

%% Some remarks.
% For this script to work you need to prepare a bit your Fiji installation
% and its connection to MATLAB.
%
% 1.
% In your Fiji, please install the 'ImageJ-MATLAB' site. This is explained
% here: https://imagej.net/scripting/matlab. Then restart Fiji.
%
% 2.
% Add the /path/to/your/Fiji.app/scripts to the MATLAB path. Either use the
% path tool in MATLAB or use the command:
% >> addpath( '/path/to/your/Fiji.app/scripts' )
%
% 3.
% In MATLAB, first launch ImageJ-MATLAB:
% >> ImageJ
%
% 4.
% You can now run this script.



%% The import lines, like in Python and Java

import java.lang.Integer

import ij.IJ

import fiji.plugin.trackmate.TrackMate
import fiji.plugin.trackmate.Model
import fiji.plugin.trackmate.Settings
import fiji.plugin.trackmate.SelectionModel
import fiji.plugin.trackmate.Logger
import fiji.plugin.trackmate.features.FeatureFilter
import fiji.plugin.trackmate.detection.LogDetectorFactory
import fiji.plugin.trackmate.tracking.jaqaman.SparseLAPTrackerFactory
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettingsIO
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettings
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer


%% The script itself.

% Get currently selected image
imp = IJ.openImage('https://fiji.sc/samples/FakeTracks.tif');
% imp = ij.ImagePlus('/Users/tinevez/Desktop/Data/FakeTracks.tif');
imp.show()


%----------------------------
% Create the model object now
%----------------------------
   
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = Model();
   
% Send all messages to ImageJ log window.
model.setLogger( Logger.IJ_LOGGER )
      
%------------------------
% Prepare settings object
%------------------------
      
settings = Settings( imp );
      
% Configure detector - We use a java map
settings.detectorFactory = DogDetectorFactory();
map = java.util.HashMap();
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', 2.5);
map.put('TARGET_CHANNEL', Integer.valueOf(1)); % Needs to be an integer, otherwise TrackMate complaints.
map.put('THRESHOLD', 0);
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;
   
% Configure spot filters - Classical filter on quality.
% All the spurious spots have a quality lower than 50 so we can add:
filter1 = FeatureFilter('QUALITY', 50, true);
settings.addSpotFilter(filter1)
    
% Configure tracker - We want to allow splits and fusions
settings.trackerFactory  = SparseLAPTrackerFactory();
settings.trackerSettings = settings.trackerFactory.getDefaultSettings(); % almost good enough
settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', true)
settings.trackerSettings.put('ALLOW_TRACK_MERGING', true)
   
% Configure track analyzers - Later on we want to filter out tracks 
% based on their displacement, so we need to state that we want 
% track displacement to be calculated. By default, out of the GUI, 
% not features are calculated. 

% Let's add all analyzers we know of.
settings.addAllAnalyzers()
   
% Configure track filters - We want to get rid of the two immobile spots at 
% the bottom right of the image. Track displacement must be above 10 pixels.
filter2 = FeatureFilter('TRACK_DISPLACEMENT', 10.0, true);
settings.addTrackFilter(filter2)
   
   
%-------------------
% Instantiate plugin
%-------------------
   
trackmate = TrackMate(model, settings);
      
%--------
% Process
%--------
   
ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end

ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end
      
%----------------
% Display results
%----------------

% Read the user default display setttings.
ds = DisplaySettingsIO.readUserDefault();

% Big lines.
ds.setLineThickness( 3. )

selectionModel = SelectionModel( model );
displayer = HyperStackDisplayer( model, selectionModel, imp, ds );
displayer.render()
displayer.refresh()
 
% Echo results
display( model.toString() )


%% EXPORTING FILE
% Exporting Script

from fiji.plugin.trackmate.visualization.hyperstack import HyperStackDisplayer
from fiji.plugin.trackmate.io import TmXmlReader
from fiji.plugin.trackmate.io import TmXmlWriter
from fiji.plugin.trackmate.io import CSVExporter
from fiji.plugin.trackmate.visualization.table import TrackTableView
from fiji.plugin.trackmate.action import ExportTracksToXML
from fiji.plugin.trackmate import Logger
from java.io import File
import sys

% We have to do the following to avoid errors with UTF8 chars generated in 
% TrackMate that will mess with our Fiji Jython.
reload(sys)
sys.setdefaultencoding('utf-8')


% This script demonstrates several ways by which TrackMate data
% can be exported to files. Mainly: 1/ to a TrackMate XML file,
% 2/ & 3/ to CSV files, 4/ to a simplified XML file, for linear tracks.


%----------------------------------
% Loading an example tracking data.
%----------------------------------

% For this script to work, you need to edit the path to the XML below.
% It can be any TrackMate file, that we will re-export in the second
% part of the script.

% Put here the path to the TrackMate file you want to load
% input_filename = '/Users/tinevez/Desktop/FakeTracks.xml'
% input_file = File( input_filename )
% 
% % We have to feed a logger to the reader.
% logger = Logger.IJ_LOGGER
% 
% reader = TmXmlReader( input_file )
% if not reader.isReadingOk():
%     sys.exit( reader.getErrorMessage() )
% 
% % Load the model.
% model = reader.getModel()
% % Load the image and tracking settings.
% imp = reader.readImage()
% settings = reader.readSettings(imp)
% % Load the display settings.
% ds = reader.getDisplaySettings()
% % Load the log.
% log = reader.getLog()
% log = """Hey, I have read this TrackMate file in a Jython 
% script and modified it before resaving it.
% Here is the original log:
% """  + log

% 
% %-------------------------------
% % 1/ Resave to a TrackMate file.
% %-------------------------------
% 
% % The following will generate a TrackMate XML file.
% % This is the file type you will be able to load with
% % the GUI, using the command 'Plugins > Tracking > Load a TrackMate file'
% % in Fiji.
% 
% target_xml_filename = input_filename.replace( '.xml', '-resaved.xml' )
% target_xml_file = File( target_xml_filename )
% writer = TmXmlWriter( target_xml_file, logger )
% 
% % Append content. Only the model is mandatory.
% writer.appendLog( log )
% writer.appendModel( model )
% writer.appendSettings( settings )
% writer.appendDisplaySettings( ds )
% 
% % We want TrackMate to show the view config panel when 
% % reopening this file.
% writer.appendGUIState( 'ConfigureViews' )
% 
% % Actually write the file.
% writer.writeToFile()



% %-------------------------------------------------------
% % 2/ Export spots data to a CSV file in a headless mode.
% %-------------------------------------------------------
% 
% % This will export a CSV table containing the spots data. The table will
% % include all spot features, their ID, the track they belong to, name etc.
% % But it will not include the edge and track features. Also if you have
% % splitting and merging events in your data, the content of the CSV file
% % will not be enough to reconstruct the tracks. 
% 
% % Nonetheless, the advantage of using this snippet, with the 'CSVExporter'
% % is that it can work in headless mode. It does not depend on Fiji GUI
% % being launched. So you can use it a 'headless' script, called from the 
% % command line. See this page for more information:
% % https://imagej.net/scripting/headless
% 
% out_file_csv = input_filename.replace( '.xml', '.csv' )
% only_visible = True % Export only visible tracks
% % If you set this flag to False, it will include all the spots,
% % the ones not in tracks, and the ones not visible.
% CSVExporter.exportSpots( out_file_csv, model, only_visible )



%----------------------------------------------------
% 3/ Export spots, edges and track data to CSV files.
%----------------------------------------------------

% The following uses the tables that are displayed in the TrackMate
% % GUI. As a consequence the snippet cannot be used in 'headless' mode.
% % If you launch the script from the Fiji script editor, we won't
% % have a problem.
% 
% % Spot table. Will contain only the spots that are in visible tracks.
% spot_table = TrackTableView.createSpotTable( model, ds )
% spot_table_csv_file = File( input_filename.replace( '.xml', '-spots.csv' ) )
% spot_table.exportToCsv( spot_table_csv_file )
% 
% % Edge table.
% edge_table = TrackTableView.createEdgeTable( model, ds )
% edge_table_csv_file = File( input_filename.replace( '.xml', '-edges.csv' ) )
% edge_table.exportToCsv( edge_table_csv_file )
% 
% % Track table.
% track_table = TrackTableView.createTrackTable( model, ds )
% track_table_csv_file = File( input_filename.replace( '.xml', '-tracks.csv' ) )
% track_table.exportToCsv( track_table_csv_file )



%------------------------------------
% 4/ Export to a simplified XML file.
%------------------------------------

% During the ISBI Single-Particle Tracking challenge the organizers used
% a special file format, in a XML fie, to store tracks. Because of the 
% scope of the challenge, this works well ONLY for linear tracks. That is:
% tracks that have no merging or splitting events. 

% The file looks like this:
%<?xml version="1.0" encoding="UTF-8"?>
%<Tracks nTracks="7" spaceUnits="pixel" frameInterval="1.0" timeUnits="sec" generationDateTime="Tue, 16 Apr 2024 18:36:11" from="TrackMate v7.12.2-SNAPSHOT-4a56a0a4e34f1590f1acc341368f2fcf336e1c80">
%  <particle nSpots="49">
%    <detection t="0" x="116.25803433315897" y="118.01058828304035" z="0.0" />
%    <detection t="1" x="116.35642718798508" y="117.70622315532961" z="0.0" />
%    <detection t="2" x="116.46312406173281" y="117.69830578342241" z="0.0" />
%    <detection t="3" x="116.3916284518453" y="117.58156664808513" z="0.0" />
% etc.

% In this folder, the MATLAB script 'importTrackMateTracks.m' can open such a file
% in MATLAB. But of course, it is not a TrackMate file that TrackMate can open.

% For this script to work, you need to edit the path to the XML below.
% It can be any TrackMate file, that we will re-export in the second
% part of the script.

% Put here the path to the TrackMate file you want to load
% input_filename = '/Users/tinevez/Desktop/FakeTracks.xml'
% input_file = File( input_filename )
% 
% % We have to feed a logger to the reader.
% logger = Logger.IJ_LOGGER
% 
% reader = TmXmlReader( input_file )
% if not reader.isReadingOk():
%     sys.exit( reader.getErrorMessage() )
% 
% % Load the model.
% model = reader.getModel()
% % Load the image and tracking settings.
% imp = reader.readImage()
% settings = reader.readSettings(imp)
% % Load the display settings.
% ds = reader.getDisplaySettings()
% % Load the log.
% log = reader.getLog()
% log = """Hey, I have read this TrackMate file in a Jython 
% script and modified it before resaving it.
% Here is the original log:
% """  + log
simple_xml_file = File(input_filename.replace( '.xml', '-simple-tracks.xml' ) )
ExportTracksToXML.export( model, settings, simple_xml_file )



