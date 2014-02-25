
// truncated tetra buttonbox part maker by dmt
// based on mathgrrl polysnap tiles

// AS SUBMITTED TO THINGIVERSE CUSTOMIZER - DO NOT MODIFY THIS COPY


full_tile(6); 
//translate([0,-6*13,0])rotate([0,0,60])full_tile(6);


//full_tile(3); 

translate([0,-6*13,0])rotate([0,0,60])full_tile(6);

translate([50,-30,0])rotate([0,0,-30])
  full_tile(3,thick=2.5, button_rad=2.5, line_thick=4, inner_circle_rad = 0);


translate([-50,-30,0])rotate([0,0,-30])
  full_tile(3,thick=2.5, button_rad=2.5, line_thick=4, inner_circle_rad = 0);


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

// Set the border thickness, in mm
border = 3.5;	

/* [Adjust Fit] */

// Add extra space between snaps, in mm
clearance = .17;

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
module full_tile(num_sides, thick=5.5, button_rad=12.5, line_thick=6, inner_circle_rad = 0){
	//radius depends on side length
	radius = side_length/(2*sin(180/num_sides)); 

	//inside radius depends on the border thickness
	inside = radius-border/(cos(180/num_sides)); 

	//width of each snap depends on number of snaps	
	snapwidth = radius*sin(180/num_sides)/snaps;

	radiusa=radius;//-thickness/2;

	outter_rad = button_rad+thick;

	circle_rad = ((inside-outter_rad)/2)/cos(angle/3);

	inner_circle_offset = circle_rad/2;

	line_length= circle_rad*2;

	translation=(button_rad+thick/2+circle_rad);

	difference(){
		union(){
			//make the polygon base
			poly_maker(num_sides,radiusa,thick,button_rad,line_thick, inner_circle_rad,line_length, translation, outter_rad,inside); 

			//make the snaps
			snap_maker(num_sides,radiusa,snapwidth);
		}
		// for extra led holes if inner_circle_rad > 0
		translate([0,0,1])linear_extrude(height=thickness,center=true)
			for(i=[0:num_sides]){
				//rotation is around the z-axis [0,0,1]
				rotate(i*360/num_sides+angle,[0,0,1])translate([0,translation+inner_circle_offset])
					circle(inner_circle_rad,center=true);
			}}
}

//////////////////////////////////////////////////////////////////////////
// MODULES ///////////////////////////////////////////////////////////////
//build the polygon shape of the tile
//shape is made up of n=num_sides wedges that are rotated around
module poly_maker(num_sides,radiusa,thick,button_rad,line_thick, inner_circle_rad, line_length, translation, outter_rad, inside){

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

//build the snaps around the tile
//try the commands alone with i=1 and i=2 to see how this works
//remember to read from the bottom to the top to make sense of this
module snap_maker(num_sides,radiusa,snapwidth){

	//rotate the side of snaps n=num_sides times at angle of 360/n each time
	for(i=[0:num_sides-1]){ 

		//rotation is around the z-axis [0,0,1]
		rotate(i*360/num_sides,[0,0,1]) 	

			//build snaps for first side at the origin and move into positions
			for(i=[0:snaps-1]){	

				//read the rest of the commands from bottom to top
				//translate the snap to the first side
				translate([radiusa,0,-thickness/2]) 

					//rotate the snap to correct angle for first side
					rotate(180/num_sides) 

					//for i^th snap translate 2*i snapwidths over from origin
					translate([0,2*i*snapwidth,0]) 
					hinge_a(thickness/2+lengthen,snapwidth-clearance,thickness/2,.01,i);
			}
	}
}


module hinge_a(bw,hl,ro,cl,i){
	ri = ro/3;
	sri = ro/2 *1.7;
	farout=-0.9;
	//if(i < snaps/2){
	// if(((i < snaps/2) || (i==snaps)) && (i!=0)){
	if (i%2 ==0){ 
		union(){     
			hinge_arm(bw,hl,ro,cl);
			//translate([bw,-farout,ro])sphere(r=sri,center=true);
			translate([bw,hl+farout,ro])sphere(r=sri,center=true);
		}

	}
	else{
		difference(){
			hinge_arm(bw,hl,ro,cl);
			translate([bw,hl+cl,ro])rotate([90,0,0])cylinder(h=hl+2*cl,r=ri*1.2);
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
