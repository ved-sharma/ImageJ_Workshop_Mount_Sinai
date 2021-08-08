// Ved P. Sharma, May 13, 2012
/* version 3: 
(a) Added the "Break statement equivalent" for terminating the for loops after the intersection point is found.
Need to work on the following features: 
1. Need to add the user selected angle theta
2. Final ROIs (or overlay) shown is pipette point, cell and the radial vectors
3. Dialog for theta after checking for roiManager.
4. Add help button.
5. Explore the possibility that setBatchMode can be started before opening the roiManager
*/
requires("1.42i");

if (roiManager("count") != 0) {
    showMessageWithCancel("Ved's macro...", "To proceed further this macro needs\nto close the ROI Manager window.");
    selectWindow("ROI Manager");
    run("Close");
}
setTool("point");
waitForUser("Point Tool selected. Click at the pipette tip.\nThen click OK.");
roiManager("Add"); // roiManager index 0
List.setMeasurements;
x2 = List.getValue("X");
y2 = List.getValue("Y");

setTool("freehand");
waitForUser("Freehand tool selected. Draw the cell periphery.\nThen click OK.");
roiManager("Add"); // roiManager index 1
List.setMeasurements;
x1 = List.getValue("X");
y1 = List.getValue("Y");

Dialog.create("Change centroid coordinates");
Dialog.addMessage("Current centroid coordinates are:");
Dialog.addNumber("X:", x1);
Dialog.addNumber("Y:", y1);
Dialog.show();
x1 = Dialog.getNumber();
y1 = Dialog.getNumber();
//

getPixelSize(unit, pw, ph);
setForegroundColor(255, 255, 255);
makeLine(x1/pw, y1/ph, x2/pw, y2/ph, 2);
roiManager("Add"); // roiManager index 2
List.setMeasurements;
len = List.getValue("Length");
alpha = List.getValue("Angle");

theta = 22.5;
for (i = theta; i<360; i+=theta) {
	xi = x1 + len*cos((alpha-theta)*(PI/180));
	yi = y1 - len*sin((alpha-theta)*(PI/180));
	makeLine(x1/pw, y1/ph, xi/pw, yi/ph, 2);
	roiManager("Add"); // roiManager index 2
	alpha = alpha - theta;
}
run("Select None");

//setBatchMode(true);
w = getWidth; h = getHeight;
setBackgroundColor(255, 255, 255);
setForegroundColor(0, 0, 0);

newImage("i1","8-bit White",w,h,1);
i1=getImageID;
// line width = 2 create more than 1 intersection points for each
run("Line Width...", "line=2");
roiManager("Select", 1); run("Draw"); // select cell and draw

L = newArray(16);
for(k=0;k<16;k++) {
	newImage("i2","8-bit White",w,h,1);
	i2=getImageID;
	roiManager("Select", k+2);
	run("Draw");
	imageCalculator("Max create", i1,i2);
	i3=getImageID;
	for (x=0;x<w;x++) {
		for (y=0;y<h;y++) {
			if (getPixel(x,y)==0) {
//				makePoint(x,y);
//				roiManager("Add");
				makeLine(x1/pw, y1/ph, x, y, 1);
				roiManager("Add");				
				List.setMeasurements;
				L[k] = List.getValue("Length");
				y = h; x = w; // equivalent to Break statement after the first intersection point is found
			}
		}
	}
	selectImage(i2); close;
	selectImage(i3); close;
}
selectImage(i1); close;

print("----------------------------------------------------------------------");
print("Length (in "+unit+") of 16 radial vectors originating from \nthe cell centroid, and which are 22.5 degrees apart, are:");
print("----------------------------------------------------------------------");
for(i=0;i<16;i++)
	print(L[i]);

setOption("Show All", 1);
