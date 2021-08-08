// This macro splits a delta vision .dv file into 2 channels, colors the 2nd channel green,
// merges both the channels and saves the mergred file in the user-specified directory.

Dir =   "C:\\Users\\Ved\\Desktop\\2015.12.18 Image analysis seminar at Mount Sinai\\data1\\";

filenames = getFileList(Dir);

pattern = ".*R3D.dv";

for(i = 0; i< filenames.length; i++) {

	if(matches(filenames[i], pattern)) {
		open(Dir+filenames[i]);
		n = nSlices;
		title = replace(getTitle, "R3D.dv", "merge");

		run("Make Substack...", "delete slices=1-"+n+"-2");
		rename("phase");
		setMinAndMax(0, 2000);
		run("Put Behind [tab]");

		rename("green");
		setMinAndMax(300, 3000);
		run("Merge Channels...", "c2=green c4=phase");
		saveAs("Tiff", Dir+title);
		close();
	}
}
