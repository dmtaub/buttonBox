/*
	Author: Ezra Reynolds
            thingiverse@shadowwynd.com

	Function:
		Example. Funnel.  Adapter from big hose to small hose.  Pressure reducer/increaser.
*/

use <tween_loft.scad>			// Define all functions (this is the main file with full documentation)
include <tween_shapes.scad>	// Define all tween shape geometries


isHollow 			= 0;				// If 1, create a tube.  If 0, create a solid.
extrusionHeight	= 100;				// Height of the loft
spacing = 1.8;
wallThickness		= 70;				// Wall Thickness - higher values add material but will seal gaps
										// Thickness is added to the exterior diameter of tu be, no effect on solids
extrusionSlices 	= 10;	

scale_default = 0.1;
sx=scale_default*1.618;
sy=scale_default;
sz=scale_default;
// ------------------------Parameters -----------------------------------------------

// The lower shape
shape1				= tween_triangle;
shape1Size 		= 200;				// Size of the lower shape
shape1Rotation 	= 0;				// Rotation of the lower shape
shape1Extension 	= 10;				// Extend the profile (space for tube clamp, etc.)
shape1Centroid  	= [0,0];			// Location of center point

// The upper shape
shape2				= tween_triangle;		
shape2Size 		= 0;				// Size of the upper shape
shape2Rotation 	= 0;				// RotationSize of the upper shape
shape2Extension 	= 10;				// Extend the profile (space for tube clamp, etc.)
shape2Centroid	= [0,0];			// Location of center point
shape2ExtensionAdjustment	= 0;	// Moves top extension down by n slices.


sliceAdjustment	= 0;				// Ensure the slices intersect by this amount, 
										// needed if OpenSCAD is generating more than 2 volumes for an STL file

sliceHeight = extrusionHeight * 1.0 / extrusionSlices;	// Calculate the height of each slice

// Generate the top level part

rotate([0,0,90])scale([sx,sy,sz])union(){
translate([0,180,0])tweenLoft(tween_triangle, shape1Size, shape1Rotation, shape1Centroid, shape1Extension,
			tween_triangle, shape2Size, shape2Rotation, shape2Centroid, shape2Extension, shape2ExtensionAdjustment,
			extrusionSlices, sliceHeight, sliceAdjustment, wallThickness/2, isHollow);
translate([400,220,0])rotate([0,0,60])translate([0,shape1Size*spacing,0])tweenLoft(tween_triangle, shape1Size, shape1Rotation, shape1Centroid, shape1Extension,
			tween_hexagon, shape2Size, shape2Rotation, shape2Centroid, shape2Extension, shape2ExtensionAdjustment,
			extrusionSlices, sliceHeight, sliceAdjustment, wallThickness/2, isHollow);
    
    translate([0,shape1Size*spacing*2,0])tweenLoft(tween_hexagon, shape1Size, shape1Rotation, shape1Centroid, shape1Extension,
			tween_triangle, shape2Size, shape2Rotation, shape2Centroid, shape2Extension, shape2ExtensionAdjustment,
			extrusionSlices, sliceHeight, sliceAdjustment, wallThickness/2, isHollow);
    
    translate([0,shape1Size*spacing*3,0])tweenLoft(tween_hexagon, shape1Size, shape1Rotation, shape1Centroid, shape1Extension,
			tween_hexagon, shape2Size, shape2Rotation, shape2Centroid, shape2Extension, shape2ExtensionAdjustment,
			extrusionSlices, sliceHeight, sliceAdjustment, wallThickness/2, isHollow);

}
// END OF FILE	S.D.G.