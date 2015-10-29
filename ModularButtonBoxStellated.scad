
// truncated tetra buttonbox part maker by dmt
// based on mathgrrl polysnap tiles

printable = -4;
spherefactor = 1.5; //was 1.7
cylfactor = 1.5; //was 1.2
x=.2    ;  // x factor to adjust fit .1 makerbot PL .22 + remove sphere for xyz
waypoint = .2;
//full_tile(3,3.5,2.5); 
full_tile(5,3.5,12.5,0,1,10, waypoint); 

//translate([-25+printable,0,0])rotate([0,0,60])full_tile(3,3.5,2.5);


/*translate([0,-63,0])rotate([0,0,90])
  full_tile(3,thick=2.5, button_rad=2.5, inner_circle_rad = 0);
* /
//full_tile(3); 

translate([10,-60,0])rotate([0,0,30])full_tile(6);
translate([-60,-60,0])rotate([0,0,35])full_tile(5);
translate([-60,0,0])rotate([0,0,45])full_tile(4);
/*
translate([30,-55,0])rotate([0,0,180])
  full_tile(3,thick=2.5, button_rad=2.5, inner_circle_rad = 0);


translate([-30,-55,0])rotate([0,0,0])
  full_tile(3,thick=2.5, button_rad=2.5, inner_circle_rad = 0);
*/

//////////////////////////////////////////////////////////////////////////
// PARAMETERS ////////////////////////////////////////////////////////////
$fn=50;
/* [Shape] */

// Choose the number of sides for the tile
//sides = 3; // [3,4,5,6,7,8,9,10,11,12]
//sides=6;

// Choose the number of snaps on each side
snaps = 4; // [2,3,4,5,6,7,8]

/* [Size] */

// Set the length of each side, in mm
side_length = 40; 

// Set the thickness of the tile, in mm
thickness = 3.5;

//percentage of sphere radius to translate
sphere_farout=-.35+x*2/3; //was .45


// Set the border thickness, in mm
border = 3.5;	

/* [Adjust Fit] */

// Add extra space between snaps, in mm
clearance = .17+x;

// Add extra length to the snaps, in mm
lengthen = .3;



//thick=2.5; //tri
//thick=5.5; // hex
//button_rad=12.5; //hex
//button_rad=2.5;//tri
//line_thick = 4; //tri
//line_thick = 6;

angle=90;

//////////////////////////////////////////////////////////////////////////
// RENDERS ///////////////////////////////////////////////////////////////
//module full_tile(num_sides, thick=5.5, button_rad=12.5, inner_circle_rad = 0){
// full-tile fillet = 0, 1, or 2 sided fillet
module full_tile(num_sides, thick=3.5, button_rad=16.5, inner_circle_rad = 0, fillet = 1, stellation_height = 10, waypoint = .4){
	//radius depends on side length
	radius = side_length/(2*sin(180/num_sides)); 
    line_thick = border/1.5/(sin(180/num_sides)); // was 6

	radiusa=radius-thickness/2/cos(180/num_sides);//-thickness/2;

	//inside radius depends on the border thickness
	inside = radiusa-border/(cos(180/num_sides)); 

	//width of each snap depends on number of snaps	-- magic formula :(
	//snapwidth = -(thickness/1.215)*sin(45)/snaps+side_length/2/snaps;
	//snapwidth = radiusa*sin(180/num_sides)/snaps;

	snapwidth = side_length/2/(snaps+1);
	//echo(snapwidth);

	outter_rad =  0; //disable for stellated : was button_rad+thick;

	circle_rad = ((inside+thickness-outter_rad)/2)/cos(angle/3);

	inner_circle_offset = circle_rad/2;

	line_length= circle_rad*2;

	translation=(button_rad+thick/2+circle_rad);

	difference(){
		union(){
			//make the polygon base
            difference(){
                poly_maker(num_sides,radius,radiusa,thick,button_rad,line_thick, line_length, translation, outter_rad, inside); 
                for (i=[0:num_sides]){
                    rotate((i+.5)*360/num_sides+angle,[0,0,1]) translate([0,radiusa,0]) 
                        translate([0,0,0])cube([2,1,5],true);
            }
            }
            //TODO: center_holder(line_thick, line_length)
            tweener( num_sides, radiusa-.3, thick, button_rad, stellation_height , waypoint);
			//make the snaps
			snap_maker(num_sides,radius,radiusa,snapwidth);
		}
		union(){
            if (fillet > 0)
                fillet_maker(num_sides,radius,radiusa,snapwidth, fillet == 2);

			// for extra led holes if inner_circle_rad > 0
			translate([0,0,1])linear_extrude(height=thickness,center=true)
				for(i=[0:num_sides]){
					//rotation is around the z-axis [0,0,1]
					rotate(i*360/num_sides+angle,[0,0,1])translate([0,translation+inner_circle_offset])
						circle(inner_circle_rad,center=true);
				}
      	}
	}
}

//////////////////////////////////////////////////////////////////////////
// MODULES ///////////////////////////////////////////////////////////////
//build the polygon shape of the tile
//shape is made up of n=num_sides wedges that are rotated around
module poly_maker(num_sides,radius,radiusa,thick,button_rad,line_thick, line_length, translation, outter_rad, inside){
	//subtract the smaller polygon from the larger polygon
	difference(){

		//extrude to thicken the polygon
		linear_extrude(height=thickness,center=true){ 
			//rotate the wedge n=num_sides times at angle of 360/n each time
			for(i=[0:num_sides]){

				//rotation is around the z-axis [0,0,1]
				rotate(i*360/num_sides,[0,0,1])	
					//make triangular wedge with angle based on number of num_sides
					polygon(

							//the three vertices of the triangle
							points =	[[0-.1,0-.1], //tweaks fix CGAL errors
							[radiusa,0-.01],
							[radiusa*cos(360/num_sides)-.01,radiusa*sin(360/num_sides)+.01]],

							//the order to connect the three vertices above
							paths = [[0,1,2]]
					       );
			}
		}
		//extrude to thicken the center polygon that will be the hole
		linear_extrude(height=thickness+2,center=true){ 

			//rotate the wedge n=num_sides times at angle of 360/n each time			
			difference(){
				for(i=[0:num_sides]){

					//rotation is around the z-axis [0,0,1]
					rotate(i*360/num_sides,[0,0,1])	

						//make triangular wedge with angle based on number of num_sides
						polygon(

								//the three vertices of the triangle
								points =	[[0-.2,0-.2], //tweaks fix CGAL errors
								[inside,0-.01],
								[inside*cos(360/num_sides)-.01,inside*sin(360/num_sides)+.01]],

								//the order to connect the three vertices above
								paths = [[0,1,2]]
						       );
				}
                if (outter_rad > 0) {
                    difference(){
                        union(){
                            for(i=[0:num_sides]){

                                //rotation is around the z-axis [0,0,1]
                                rotate(i*360/num_sides+angle,[0,0,1])translate([0,translation])
                                    //circle(circle_rad,center=true);
                                    square([line_thick,line_length],center=true);
                            }
                            circle(outter_rad);
                        }
                        union(){
                            circle(button_rad);
                        }
                    }
                }
			}
		}
	}
}

//build the snaps around the tile
//try the commands alone with i=1 and i=2 to see how this works
//remember to read from the bottom to the top to make sense of this
module snap_maker(num_sides,radius, radiusa,snapwidth){

	//rotate the side of snaps n=num_sides times at angle of 360/n each time
	for(i=[0:num_sides-1]){ 

		//rotation is around the z-axis [0,0,1]
		rotate(i*360/num_sides,[0,0,1]) 	
			union(){
			//build snaps for first side at the origin and move into positions
			for(i=[0:snaps-1]){	

				//read the rest of the commands from bottom to top
				//translate the snap to the first side
				translate([radius,0,-thickness/2]) 

					//rotate the snap to correct angle for first side
					rotate(180/num_sides,[0,0,1]) 

					//for i^th snap translate 2*i snapwidths over from origin
					translate([-thickness/2,2*(i+.5)*snapwidth+clearance/2,0]) 
						union(){
							hinge_a(thickness/2+lengthen,snapwidth-clearance,thickness/2,.01,i);
						}
			}
 		}
	}
}
angleclear = 1;

module fillet_maker(num_sides,radius, radiusa, snapwidth, both = true){

	//rotate the side of snaps n=num_sides times at angle of 360/n each time
	for(j=[0:num_sides-1]){ 
		rotate(j*360/num_sides,[0,0,1]) 	

			translate([radius,0,-thickness/2]) 
					//rotate the snap to correct angle for first side
			rotate(180/num_sides,[0,0,1]) 
				translate([-angleclear,0,angleclear])
					translate([-thickness/2,2*(snaps)*snapwidth,0]) 
						union(){
							translate([0,snapwidth-clearance/2,-angleclear])
								rotate([0,45,0])cube([angleclear*2,snapwidth+clearance,angleclear*2]);
							if(both)
                                translate([0,snapwidth-clearance/2,thickness-angleclear])
                                    rotate([0,45,0])cube([angleclear*2,snapwidth+clearance,angleclear*2]);
						}
		//rotation is around the z-axis [0,0,1]
		rotate(j*360/num_sides,[0,0,1]) 	
			union(){
			//build snaps for first side at the origin and move into positions
			for(i=[0:snaps-1]){	

				//read the rest of the commands from bottom to top
				//translate the snap to the first side
				translate([radius,0,-thickness/2]) 

					//rotate the snap to correct angle for first side
					rotate(180/num_sides,[0,0,1]) 

					//for i^th snap translate 2*i snapwidths over from origin
				translate([-angleclear,0,angleclear])
					translate([-thickness/2,2*(i+.5)*snapwidth,0]) 
						union(){
							translate([0,snapwidth-clearance/2,-angleclear])
								rotate([0,45,0])cube([angleclear*2,snapwidth+clearance,angleclear*2]);
							if (both)
                                translate([0,snapwidth-clearance/2,thickness-angleclear])
                                    rotate([0,45,0])cube([angleclear*2,snapwidth+clearance,angleclear*2]);
						}
		
			}
 		}
	}
}

module hinge_a(bw,hl,ro,cl,i){
	ri = ro/3;
	sri = ro/2 * spherefactor;
	//if(i < snaps/2){
	// if(((i < snaps/2) || (i==snaps)) && (i!=0)){
	if (i%2 ==0){ 
		union(){     
			hinge_arm(bw,hl,ro,cl);
			//translate([bw,-farout,ro])sphere(r=sri,center=true);
			translate([bw,(hl-sri/4)+sphere_farout*sri,ro])
				difference(){
					sphere(r=sri,center=true);
					translate([-.05,-sri-sri*sphere_farout,-.05])cube(sri*2+.1,center=true);
				}
		}

	}
	else{
		difference(){
			hinge_arm(bw,hl,ro,cl);
			translate([bw,hl+cl,ro])rotate([90,0,0])cylinder(h=hl+2*cl,r=ri*cylfactor);
		}
	}
}

module hinge_arm(BLOCKWIDTH,h_len,rad_o,clip){
	union(){
		translate([-clip,clip,0]) cube([BLOCKWIDTH,h_len-clip,rad_o*2]);
		//difference(){
		translate([BLOCKWIDTH-clip,h_len,rad_o]) rotate([90,0,0]) cylinder(r=rad_o,h=h_len-clip);
		//translate([-rad_o/2-clip,-clip,-clip]) cube([BLOCKWIDTH/2,BLOCKWIDTH/3,rad_o*2+2*clip]);
		//}
	}
}





use <tween_loft.scad>			// Define all functions (this is the main file with full documentation)
include <tween_shapes.scad>	// Define all tween shape geometries

// ------------------------Parameters -----------------------------------------------
module tweener( num_sides, radius, thick, button_rad, stellation_height, waypointStop = .5 ) {
    shapes = [0,0,0, tween_triangle, tween_square, tween_pentagon, tween_hexagon];
    shapes2 = [0,0,0, tween_triangle, tween_square, tween_circle, tween_circle];
    shape1 = shapes[num_sides];
    
    
    // The lower shape
    shape1Size 		= radius-thick/2;				// Size of the lower shape
    shape1Rotation 	= 0;				// Rotation of the lower shape
    shape1Extension 	= 3.5;				// Extend the profile (space for tube clamp, etc.)
    shape1Centroid  	= [0,0];			// Location of center point


    // The middle shape
    waypoint = shape1;
    waypointSize 		= waypointStop*(button_rad-shape1Size)+shape1Size; //waypointStop*radius+(1-waypointStop)*button_rad;				
    // Size of the lower shape
    waypointRotation 	= 0;				// Rotation of the lower shape
    waypointExtension 	= 0;				// Extend the profile (space for tube clamp, etc.)
    waypointCentroid  	= [0,0];			// Location of center point


    // The upper shape
    shape2			= shapes2[num_sides];		
    shape2Size 		= button_rad;				// Size of the upper shape
    shape2Rotation 	= 0;				// RotationSize of the upper shape
    shape2Extension 	= 0;				// Extend the profile (space for tube clamp, etc.)
    shape2Centroid	= [0,0];			// Location of center point
    shape2ExtensionAdjustment	= 0;	// Moves top extension down by n slices.

    wallThickness		= thick;				// Wall Thickness - higher values add material but will seal gaps
                                            // Thickness is added to the exterior diameter of tu be, no effect on solids
                    
    isHollow 			= 1;				// If 1, create a tube.  If 0, create a solid.

    extrusionHeight	= stellation_height;				// Height of the loft

    extrusionSlices = 20; //47; //max that i've seen work	
    sliceAdjustment	= 0;				// Ensure the slices intersect by this amount, 
                                            // needed if OpenSCAD is generating more than 2 volumes for an STL file

    sliceHeight = extrusionHeight * 1.0 / extrusionSlices;	// Calculate the height of each slice
    firstSetCount = round(extrusionSlices*waypointStop);
    secondSetCount = round(extrusionSlices*(1-waypointStop));

    // Generate the top level part
    translate([0,0,shape1Extension/2])
    union(){
    tweenLoft(shape1, shape1Size, shape1Rotation, shape1Centroid, shape1Extension,
                shape1, waypointSize, waypointRotation, waypointCentroid, waypointExtension, 0,
                firstSetCount, sliceHeight, sliceAdjustment, wallThickness/2, isHollow);
  
    translate([0,0,stellation_height*waypointStop])
        tweenLoft(waypoint, waypointSize, waypointRotation, waypointCentroid, waypointExtension,
                shape2, shape2Size, shape2Rotation, shape2Centroid, shape2Extension, shape2ExtensionAdjustment,
                secondSetCount, sliceHeight, sliceAdjustment, wallThickness/2, isHollow);
    }
}
