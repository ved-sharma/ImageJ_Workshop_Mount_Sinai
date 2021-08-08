// This macro is for drawing an area within certain distance from the leading
// edge of a cell. User needs to draw a segmented line at the leading edge.
//
// Author: Ved P. Sharma,     November 30, 2011
// version 3: Dialog now displays the correct unit of length. Added help button.

requires("1.46b");
if(selectionType() != 6) {
	setTool(5);
	exit("***** ERROR *****     \nBefore running this macro, draw a\nsegmented line along the cell leading edge.");
}
getSelectionCoordinates(x, y);
n = x.length;
getPixelSize(unit, pw, ph);
//print(unit); print(pw);print(ph);
Dialog.create("Leading edge measurement...");
Dialog.addNumber("Distance inside the cell ("+unit+"):", 1);
Dialog.addHelp(message());
Dialog.show();
dist = Dialog.getNumber();
if(dist <= 0)
	exit("Error: Line thickness can not be zero or negative.");
d = dist/pw;
roiManager("Add");
p = newArray(n); q = newArray(n);
// first point
m = (y[1]-y[0])/(x[1]-x[0]);
r = d/sqrt(1+(1/(m*m)));
posRoot_x = x[0] + r;
negRoot_x = x[0] - r;
if(m == 0) {
	posRoot_y = y[0] + d;
	negRoot_y = y[0] - d;
} else {
	posRoot_y = y[0] - (1/m)*(posRoot_x - x[0]);
	negRoot_y = y[0] - (1/m)*(negRoot_x - x[0]);
}
makeLine(x[0], y[0], posRoot_x, posRoot_y, 4);
getStatistics(area1, mean1);
makeLine(x[0], y[0], negRoot_x, negRoot_y, 4);
getStatistics(area1, mean2);
if (mean1 == mean2) {
	print("problem at point # "+1);
	exit("Both sides of the line are very similar in intensity.");
}
if(mean1 > mean2 ) {
	p[0] = posRoot_x; q[0] = posRoot_y;
} else {
	p[0] = negRoot_x; q[0] = negRoot_y;
}
//print("p= "+p[0]+" q= "+q[0]);

// Next n-2 points
for (i=1; i<n-1; i++) {
	makeLine(x[i-1], y[i-1], x[i], y[i]);
	wait(10);
	List.setMeasurements
	angle1 = List.getValue("Angle");
	makeLine(x[i], y[i], x[i+1], y[i+1]);
	wait(10);
	List.setMeasurements
	angle2 = List.getValue("Angle");
	m = -tan((PI/180)*(angle1+angle2)*0.5);
//print(angle1); print(angle2);print(m);
	r = d/sqrt(1+(1/(m*m)));
	posRoot_x = x[i] + r;
	negRoot_x = x[i] - r;
	if(m == 0) {
		posRoot_y = y[i] + d;
		negRoot_y = y[i] - d;
	} else {
		posRoot_y = y[i] - (1/m)*(posRoot_x - x[i]);
		negRoot_y = y[i] - (1/m)*(negRoot_x - x[i]);
	}
	makeLine(x[i], y[i], posRoot_x, posRoot_y, 4);
	getStatistics(area1, mean1);
	makeLine(x[i], y[i], negRoot_x, negRoot_y, 4);
	getStatistics(area1, mean2);
	if (mean1 == mean2) {
		print("problem at point # "+(i+1));
		exit("Both sides of the line are very similar in intensity.");
	}
	if(mean1 > mean2 ) {
		p[i] = posRoot_x; q[i] = posRoot_y;
	} else {
		p[i] = negRoot_x; q[i] = negRoot_y;
	}
//print("p= "+p[i]+" q= "+q[i]);
}

// last point
m = (y[n-1]-y[n-2])/(x[n-1]-x[n-2]);
r = d/sqrt(1+(1/(m*m)));
posRoot_x = x[n-1] + r;
negRoot_x = x[n-1] - r;
if(m == 0) {
	posRoot_y = y[n-1] + d;
	negRoot_y = y[n-1] - d;
} else {
	posRoot_y = y[n-1] - (1/m)*(posRoot_x - x[n-1]);
	negRoot_y = y[n-1] - (1/m)*(negRoot_x - x[n-1]);
}
makeLine(x[n-1], y[n-1], posRoot_x, posRoot_y, 4);
getStatistics(area1, mean1);
makeLine(x[n-1], y[n-1], negRoot_x, negRoot_y, 4);
getStatistics(area1, mean2);
if (mean1 == mean2) {
	print("problem at point # "+1);
	exit("Both sides of the line are very similar in intensity.");
}
if(mean1 > mean2 ) {
	p[n-1] = posRoot_x; q[n-1] = posRoot_y;
} else {
	p[n-1] = negRoot_x; q[n-1] = negRoot_y;
}
//print("p= "+p[0]+" q= "+q[0]);
makeSelection("polyline", p, q);
//roiManager("Add");

//composite roi
xx = newArray(2*n); yy = newArray(2*n);
for (i=0; i<n; i++) {
	xx[i] = x[i]; yy[i] = y[i];
}
for (i=0; i<n; i++) {
	xx[n+i] = p[n-1-i]; yy[n+i] = q[n-1-i];
}
makeSelection("polygon", xx, yy);
roiManager("Add");

function message() {
	return "<html>"
	+"<h3>ImageJ macro: Outline leading edge segment</h3>"
	+"version 3, November 30, 2011<br>"
	+"Author: Ved P. Sharma<br><br>"
	+"<u>For any questions, contact:</u><br>"
	+"ved.sharma@einstein.yu.edu<br>"
	+"Laboratory of John Condeelis<br>"
	+"Albert Einstein College of Medicine, New York.<br>";
}
