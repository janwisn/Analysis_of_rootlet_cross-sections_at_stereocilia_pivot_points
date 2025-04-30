Dialog.create(" ");
Dialog.addMessage("                  Analysis of stereocilia inflection region", 30, "Red");
Dialog.addMessage("                                      Jan Wisniewski", 30, "Blue");
Dialog.addMessage("      Experimental Immunology Branch, NCI, NIH, Bethesda, MD, USA", 24, "Blue");
Dialog.show();

showMessage("This macro allows selection and averaging of multiple circular / dot-like structures.\nAbberior's obf files (containing TWO STED channels) have to be converted into 16-bit tif format.\nMacro Processing steps:\n* selection of suitable images\n* ");

res=getDir("Results");

Dialog.create(" ");
Dialog.addRadioButtonGroup("Choose starting point", newArray("Select images", "Select structures"), 2, 1, "Select images");
Dialog.show();
stp=Dialog.getRadioButton();

if(stp=="Select images") {src=getDir("Source");
lst=getFileList(src);

for (i = 0; i < lst.length; i++) {open(src + lst[i]);
ttl=File.nameWithoutExtension;
getDimensions(width, height, channels, slices, frames);
if(channels>1) {run("Split Channels");		}
run("Tile");

Dialog.createNonBlocking("Title");
if(i==0) {Dialog.addMessage("Enter protein names even is skipping 1st image!");
Dialog.addString("1st STED channel name", " ");
Dialog.addToSameRow();
Dialog.addChoice("display in:", newArray("Blue", "Cyan", "Green", "Yellow", "Red", "Magenta"), "Red");
Dialog.addString("2nd STED channel name", "ACT");
Dialog.addToSameRow();
Dialog.addChoice("display in:", newArray("Blue", "Cyan", "Green", "Yellow", "Red", "Magenta"), "Green");		}
Dialog.addRadioButtonGroup("Action:", newArray("Close all extra channels, then click on the 1st STED channel before proceeding", "Skip this immage", "Skip all remaining images"), 2, 1, "Close all extra channels, then click on the 1st STED channel before proceeding");
Dialog.show();

if(i==0) {trg1=Dialog.getString();
clr1=Dialog.getChoice();
trg2=Dialog.getString();
clr2=Dialog.getChoice();
myDir1=res + trg1 + "_" + trg2 + File.separator;
File.makeDirectory(myDir1);			}
skp=Dialog.getRadioButton();

if(skp=="Close all extra channels, then click on the 1st STED channel before proceeding") {rename("S1");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
run("Put Behind [tab]");
rename("S2");
resetMinAndMax;
run("Enhance Contrast", "saturated=0.35");
run("Merge Channels...", "c1=S1 c2=S2 create ignore");
saveAs("Tif", myDir1 + ttl);		}
if(skp=="Skip all remaining images") {i=lst.length;	}
nim=nImages;
for (j = 0; j < nim; j++) {close();	}		}
stp="Select structures +";		}

if(stp=="Select structures") {lst0=getFileList(res);

Dialog.create(" ");
Dialog.addMessage("Select folder containing images selected earlier with this macro");
for (l = 0; l < lst0.length; l++) {Dialog.addCheckbox(lst0[l], false);		}
Dialog.show();
for (l = 0; l < lst0.length; l++) {fsel=Dialog.getCheckbox();
if(fsel==1) {fsel=substring(lst0[l], 0, indexOf(lst0[l], "/"));
l = lst0.length;		}		}
trg1=substring(fsel, 0, indexOf(fsel, "_"));
trg2=substring(fsel, indexOf(fsel, "_")+1);
stp="Select structures +";		}

if(stp=="Select structures +") {myDir1=res + fsel + File.separator;
myDir4=res + fsel + "_dots" + File.separator;
File.makeDirectory(myDir4); 
myDir2=res + trg1 + File.separator;
File.makeDirectory(myDir2);
myDir3=res + trg2 + File.separator;
File.makeDirectory(myDir3); 

lst1=getFileList(myDir1);
for (i = 0; i < lst1.length; i++) {open(myDir1 + lst1[i]);
getDimensions(width, height, channels, slices, frames);
ttl=File.nameWithoutExtension;
if(slices>1) {waitForUser("Select slice");
run("Duplicate...", " ");
close(lst1[i]);		}
rename("img");
run("Scale...", "x=5 y=5 z=1.0 depth=2 interpolation=None average process create");
rename("IM");
selectWindow("img");	
run("Scale...", "x=5 y=5 z=1.0 depth=2 interpolation=Bicubic average process create");
rename("x");		
run("Split Channels");
selectWindow("C1-x");
run("RGB Color");
selectWindow("C2-x");
run("RGB Color");
run("Images to Stack", "use");
close("img");
setTool("point");
if(i==0) {sslc=1;		}
for (k = 0; k < 100; k++) {selectImage("Stack");
setSlice(sslc);
Dialog.createNonBlocking("Title");
if(i==0) {if(k==0) {Dialog.addRadioButtonGroup("Choose channel used for selection:", newArray("1", "2"), 1, 2, "1");	}	}
Dialog.addCheckbox("Skip to the next image", false);
Dialog.addMessage("OR click on the center of the structure to select it");
Dialog.show();
if(i==0) {if(k==0) {sslc=Dialog.getRadioButton();		}	}
skp=Dialog.getCheckbox();
if(skp==1) {k=100;		}
else {run("Enlarge...", "enlarge=50 pixel");
run("Select None");
selectImage("IM");
run("Restore Selection");
run("Duplicate...", "duplicate");
run("Select None");
saveAs("Tif", myDir4 + ttl + "_dot_" + k+1);
close();
run("Select None");
run("Put Behind [tab]");		}		}
nim=nImages;
for (m = 0; m < nim; m++) {close();		}		}		}		

lst4=getFileList(myDir4);
for (i = 0; i < lst4.length; i++) {open(myDir4 + lst4[i]);
ttx=File.nameWithoutExtension;
rename("x");
run("Split Channels");
run("Tile");
imsel=getBoolean("Keep this region?");
if(imsel==1) {selectWindow("C1-x");
saveAs("Tif", myDir2 + ttx);
selectWindow("C2-x");
saveAs("Tif", myDir3 + ttx);	}
close();
close();	}

open(myDir2);
rename("ST");
slcs=nSlices;
for (i = 1; i < slcs+1; i++) {selectWindow("ST");
setSlice(i);
run("Duplicate...", "use");
rename("im"+i);
lw=getValue("Median")/2;
hg=getValue("Max")*1.5;
setMinAndMax(lw, hg);
run("Apply LUT");		}
close("ST");
run("Images to Stack", "use");
run("Gaussian Blur...", "sigma=2 stack");
rename("SR");

open(myDir3);
rename("ST");
slcs=nSlices;
for (i = 1; i < slcs+1; i++) {selectWindow("ST");
setSlice(i);
run("Duplicate...", "use");
rename("im"+i);
lw=getValue("Median")/2;
hg=getValue("Max")*1.5;
setMinAndMax(lw, hg);
run("Apply LUT");		}
close("ST");
run("Images to Stack", "use");
run("Gaussian Blur...", "sigma=2 stack");
rename("Y");
run("Z Project...", "projection=[Average Intensity]");
rename("G");

selectWindow("SR");
run("Z Project...", "projection=[Average Intensity]");
rename("R");

run("Merge Channels...", "c1=R c2=G create keep");
run("RGB Color");
close("Composite");
selectImage("R");
run("RGB Color");
selectImage("G");
run("RGB Color");


run("Images to Stack", "use");
run("Select All");
run("Enlarge...", "enlarge=-10 pixel");
run("Crop");
run("Set Scale...", "distance=5 known=25 unit=nm");
run("Scale...", "x=2.0 y=2.0 z=1.0 width=203 height=203 depth=3 interpolation=Bicubic average process create");
run("Make Montage...", "columns=3 rows=1 scale=1");
run("Flip Horizontally");
saveAs("Tif");
run("Scale Bar...", "width=200 height=100 thickness=2 font=0 bold");
saveAs("Tif");
nim=nImages;
for (m = 0; m < nim; m++) {close();		}		





