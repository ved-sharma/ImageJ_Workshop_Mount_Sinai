/* 
This macro lists the cell centroid coordinates in an 8-bit binary (thresholded) stack.
Run fill holes after thresholding the stack.
This macro is written for H2B labeled nucleus tracking.

starting version 7b
Version 7c = version 7b + shape descriptors (Cicularity, AR, Roundness) reporting
*/

// Ved P. Sharma, November 4, 2015, version 07c

if(!((selectionType() == 4) || (selectionType() == 3)))
	exit("Trace the cell using either wand tool or the freehand selection in the start slice.");
startSlice = getSliceNumber();
num = nSlices;
for(i=0; i<num; i++) {
	setSlice(i+1);
	if(!is("binary"))
		exit("ERROR:\nSlice #"+(i+1)+" is not binary.\nThis macro only works with a thresholded 8-bit binary stack.");
}
setSlice(startSlice);

List.setMeasurements;
inc = floor(List.getValue("Feret")/3);
Dialog.create("Cell Centroid Tracking...");
Dialog.addMessage("This macro needs a thresholded binary stack with\nvalues inside cell 255 and outside 0\nImportant: Run fill holes after thresholding the stack!");
Dialog.addNumber("Track till slice no.", nSlices);
Dialog.addMessage("For cell area changes from one frame to the next:");
Dialog.addNumber("Lower area tolerance (0-1): ", 0.5);
Dialog.addNumber("Upper area tolerance (>1): ", 2);
Dialog.addMessage("Search parameters:");
Dialog.addNumber("max Search distance (pixels):", 15*inc);
Dialog.addNumber("Search increment (pixels):", inc);
Dialog.addMessage("Notes:\nSuggested increment = Feret's diamter/ 3\nSuggested max distance = 15*increment");
Dialog.addCheckbox("List all shape descriptors (Circ, AR, Roundness)", false);
Dialog.addCheckbox("List Aspect Ratio", false);
Dialog.show();

endSlice = Dialog.getNumber();
lowerAreaTol = Dialog.getNumber();
upperAreaTol = Dialog.getNumber();
maxDist = Dialog.getNumber();
inc = Dialog.getNumber();
sd = Dialog.getCheckbox();
ar = Dialog.getCheckbox();

getPixelSize(unit, pw, ph);
//print(unit); print(pw);print(ph);
//startSlice = getSliceNumber();
n = endSlice-startSlice+1;
x = newArray(n);
y = newArray(n);
if(sd) {
	circ = newArray(n);
	AR = newArray(n);
	roundness = newArray(n);
} 
else if(ar)
	AR = newArray(n);

run("Overlay Options...", "stroke=red width=1 fill=none set");
run("Add Selection...");
var previousArea, currentArea; // global variables
previousArea = List.getValue("Area");
x[0] = (List.getValue("X")); // in microns if the image is calibrated
y[0] = (List.getValue("Y"));
if(sd){
	circ[0] = (List.getValue("Circ."));
	AR[0] = (List.getValue("AR"));
	roundness[0] = (List.getValue("Round"));
}
else if(ar)
	AR[0] = (List.getValue("AR"));
for(i=1;i<n;i++) {
	setSlice(startSlice+i);
	p = x[i-1]/pw; q = y[i-1]/ph;
	doWand(p, q);
	List.setMeasurements;
	currentArea = List.getValue("Area");
	if(currentArea > upperAreaTol*previousArea || currentArea < lowerAreaTol*previousArea || getPixel(p, q) != 255) {
		findNewCentroid(x[i-1], y[i-1]);
	}
	x[i] = (List.getValue("X"));
	y[i] = (List.getValue("Y"));
	if(sd){
		circ[i] = (List.getValue("Circ."));
		AR[i] = (List.getValue("AR"));
		roundness[i] = (List.getValue("Round"));
	}
	else if (ar)
		AR[i] = (List.getValue("AR"));
	previousArea = currentArea;
	run("Add Selection...");
}
print("--------------------------------------------------------");
print("The cell centroid coordinates (in "+unit+"):");
if(sd){
	print("Slice #\tX\tY\tCircularity\tAspect ratio\tRoundness");
	for(i=0;i<n;i++)
		print((startSlice+i)+"\t"+x[i]+"\t"+y[i] +"\t"+circ[i] +"\t"+AR[i] +"\t"+roundness[i]);
}
else if (ar) {
	print("Slice #\tX\tY\tAspect ratio");
	for(i=0;i<n;i++)
		print((startSlice+i)+"\t"+x[i]+"\t"+y[i] +"\t"+AR[i]);
}
else {
	print("Slice #\tX\tY");
	for(i=0;i<n;i++)
		print((startSlice+i)+"\t"+x[i]+"\t"+y[i]);
}
run("Select None");
setSlice(startSlice);

//-------------------------------------------
function findNewCentroid(a, b) {
//print("slice# "+getSliceNumber());
	for(rad=inc; rad<maxDist; rad+=inc) { // rad runs over the search radius
		for(angle=0, k=1; angle<2*PI; k++) {	// k runs over the angle from 0 to 2*PI
			p = (a/pw) + rad*cos(angle); q = (b/pw) + rad*sin(angle);
//makePoint(p,q);
//roiManager("Add");
	 		doWand(p, q);
			List.setMeasurements;
			currentArea = List.getValue("Area");
			if(currentArea < upperAreaTol*previousArea && currentArea > lowerAreaTol*previousArea && getPixel(p, q) == 255)
				return;
			angle = (k*inc)/rad;
		}
	}
	exit("No centroid found in the search range.\nTry increasing the search distance.");
}

