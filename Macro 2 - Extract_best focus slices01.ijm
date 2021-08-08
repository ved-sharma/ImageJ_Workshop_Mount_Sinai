// This macro works on a folder of stacks. For each stack it finds the best
// focus slices and copies it to destination folder.
//
// Ved P. Sharma, November 09, 2015

dirS = "d:\\Users\\vsharma1\\Condeelis Lab\\Meetings and Presentations\\2015.12.18 Image analysis seminar at Mount Sinai\\data2\\";
dirD = "d:\\Users\\vsharma1\\Condeelis Lab\\Meetings and Presentations\\2015.12.18 Image analysis seminar at Mount Sinai\\data2 - best focus slices\\";

var maxSlice; //global variable

filenames = getFileList(dirS);

pattern = ".*TIRF.*";

//setBatchMode(true);
for(i = 0; i< filenames.length; i++) {
	if(matches(filenames[i], pattern)) {
		open(dirS+filenames[i]);
		findBestFocusSlice();
		title = replace(getTitle, ".TIF", "_z"+maxSlice);
		run("Duplicate...", " ");
		run("Enhance Contrast", "saturated=0.3");
		saveAs("Tiff", dirD+title);
		close();
		close();
	}
}
//setBatchMode(false);

function findBestFocusSlice() {
	run("Duplicate...", "duplicate");
	run("Find Edges", "stack");
	n = nSlices;
	max = 0;
	maxSlice = 1;
	for (i=0; i<n;i++) {
		setSlice(i+1);
		getStatistics(area, mean);
		if(mean>max) {
			max = mean;
			maxSlice = i+1;
		}
	}
	close;
	setSlice(maxSlice);
//print("Best focus slice is "+maxSlice);
}
