
// truncated tetra buttonbox part maker by dmt
// based on mathgrrl polysnap tiles

// AS SUBMITTED TO THINGIVERSE CUSTOMIZER - DO NOT MODIFY THIS COPY

var=24;
full_tile(6); 
//translate([0,-6*13,0])rotate([0,0,60])full_tile(6);


/*translate([0,-63,0])rotate([0,0,90])
  full_tile(3,thick=2.5, button_rad=2.5, inner_circle_rad = 0);
*/
//full_tile(3); 
/*
translate([0,-110,0])rotate([0,0,60])full_tile(6);
//translate([0,-180,0])rotate([0,0,60])full_tile(6);

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
sphere_farout=-.35; //was .45


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
module full_tile(num_sides, thick=5.5, button_rad=12.5, inner_circle_rad = 0){
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

	outter_rad = button_rad+thick;

	circle_rad = ((inside+thickness-outter_rad)/2)/cos(angle/3);

	inner_circle_offset = circle_rad/2;

	line_length= circle_rad*2;

	translation=(button_rad+thick/2+circle_rad);

	difference(){
		union(){
			//make the polygon base
			poly_maker(num_sides,radius,radiusa,thick,button_rad,line_thick, inner_circle_rad,line_length, translation, outter_rad,inside); 

			//make the snaps
			snap_maker(num_sides,radius,radiusa,snapwidth);
		}
		// for extra led holes if inner_circle_rad > 0
		translate([0,0,1])linear_extrude(height=thickness,center=true)
			for(i=[0:num_sides]){
				//rotation is around the z-axis [0,0,1]
				rotate(i*360/num_sides+angle,[0,0,1])translate([0,translation+inner_circle_offset])
					circle(inner_circle_rad,center=true);
			}
translate([0,-1.65,-1.5])scale([1.25,1.25,1])translate([0,-11.7,0])cube([10,1.75,2],center=true);
}
}

//////////////////////////////////////////////////////////////////////////
// MODULES ///////////////////////////////////////////////////////////////
//build the polygon shape of the tile
//shape is made up of n=num_sides wedges that are rotated around
module poly_maker(num_sides,radius,radiusa,thick,button_rad,line_thick, inner_circle_rad, line_length, translation, outter_rad, inside){
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
					*polygon(

							//the three vertices of the triangle
							points =	[[0-.1,0-.1], //tweaks fix CGAL errors
							[radius,0-.01],
							[radius*cos(360/num_sides)-.01,radius*sin(360/num_sides)+.01]],

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
						rotate(i*360/num_sides,[0,0,1])	

						//make triangular wedge with angle based on number of num_sides
						polygon(

								//the three vertices of the triangle
								points =	[[0-.2,0-.2], //tweaks fix CGAL errors
								[var,0-.01],
								[var*cos(360/num_sides)-.01,var*sin(360/num_sides)+.01]],

								//the order to connect the three vertices above
								paths = [[0,1,2]]
						       );
						}
					}
					union(){
						//#import("holes.dxf");
						joyholes();
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

			//build snaps for first side at the origin and move into positions
			for(i=[0:snaps-1]){	

				//read the rest of the commands from bottom to top
				//translate the snap to the first side
				translate([radius,0,-thickness/2]) 

					//rotate the snap to correct angle for first side
					rotate(180/num_sides) 

					//for i^th snap translate 2*i snapwidths over from origin
					translate([-thickness/2,2*(i+.5)*snapwidth+clearance/2,0]) 
					hinge_a(thickness/2+lengthen,snapwidth-clearance,thickness/2,.01,i);
			}
	}
}

module hinge_a(bw,hl,ro,cl,i){
	ri = ro/3;
	sri = ro/2 *1.7;
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




// Module names are of the form poly_<inkscape-path-id>().  As a result,
// you can associate a polygon in this OpenSCAD program with the corresponding
// SVG element in the Inkscape document by looking for the XML element with
// the attribute id="inkscape-path-id".

// fudge value is used to ensure that subtracted solids are a tad taller
// in the z dimension than the polygon being subtracted from.  This helps
// keep the resulting .stl file manifold.
fudge = 0.1;

module poly_path4925(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
  
      polygon([[34.235143,-36.162630],[34.047003,-34.744506],[33.506972,-33.445059],[32.651633,-32.327655],[31.517571,-31.455658],[30.195369,-30.909530],[28.800000,-30.727487],[27.404630,-30.909530],[26.082428,-31.455658],[24.948366,-32.327655],[24.093028,-33.445059],[23.552997,-34.744506],[23.364857,-36.162630],[23.552997,-37.580755],[24.093028,-38.880202],[24.948366,-39.997606],[26.082428,-40.869602],[27.404631,-41.415731],[28.800000,-41.597773],[30.195369,-41.415731],[31.517571,-40.869602],[32.651634,-39.997606],[33.506972,-38.880202],[34.047003,-37.580755],[34.235143,-36.162630],[34.235143,-36.162630]]);
  
}

module poly_path4287(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      polygon([[-23.364857,39.437367],[-23.552997,40.855492],[-24.093028,42.154939],[-24.948367,43.272343],[-26.082429,44.144339],[-27.404631,44.690468],[-28.800000,44.872510],[-30.195370,44.690468],[-31.517572,44.144339],[-32.651634,43.272343],[-33.506972,42.154939],[-34.047003,40.855492],[-34.235143,39.437367],[-34.047003,38.019243],[-33.506972,36.719796],[-32.651634,35.602392],[-31.517572,34.730395],[-30.195369,34.184267],[-28.800000,34.002224],[-27.404631,34.184267],[-26.082429,34.730395],[-24.948366,35.602392],[-24.093028,36.719796],[-23.552997,38.019243],[-23.364857,39.437367],[-23.364857,39.437367]]);
  
}

module poly_path4921(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
  
      polygon([[34.235143,39.437367],[34.047003,40.855492],[33.506972,42.154939],[32.651633,43.272343],[31.517571,44.144339],[30.195369,44.690468],[28.800000,44.872510],[27.404630,44.690468],[26.082428,44.144339],[24.948366,43.272343],[24.093028,42.154939],[23.552997,40.855492],[23.364857,39.437367],[23.552997,38.019243],[24.093028,36.719796],[24.948366,35.602392],[26.082428,34.730395],[27.404631,34.184267],[28.800000,34.002224],[30.195369,34.184267],[31.517571,34.730395],[32.651634,35.602392],[33.506972,36.719796],[34.047003,38.019243],[34.235143,39.437367],[34.235143,39.437367]]);
 
}

module poly_path4923(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      polygon([[-23.364857,-36.162630],[-23.552997,-34.744506],[-24.093028,-33.445059],[-24.948367,-32.327655],[-26.082429,-31.455658],[-27.404631,-30.909530],[-28.800000,-30.727487],[-30.195370,-30.909530],[-31.517572,-31.455658],[-32.651634,-32.327655],[-33.506972,-33.445059],[-34.047003,-34.744506],[-34.235143,-36.162630],[-34.047003,-37.580755],[-33.506972,-38.880202],[-32.651634,-39.997606],[-31.517572,-40.869602],[-30.195369,-41.415731],[-28.800000,-41.597773],[-27.404631,-41.415731],[-26.082429,-40.869602],[-24.948366,-39.997606],[-24.093028,-38.880202],[-23.552997,-37.580755],[-23.364857,-36.162630],[-23.364857,-36.162630]]);
}

module poly_path4337(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      polygon([[34.235143,-36.162630],[34.047003,-34.744506],[33.506972,-33.445059],[32.651633,-32.327655],[31.517571,-31.455658],[30.195369,-30.909530],[28.800000,-30.727487],[27.404630,-30.909530],[26.082428,-31.455658],[24.948366,-32.327655],[24.093028,-33.445059],[23.552997,-34.744506],[23.364857,-36.162630],[23.552997,-37.580755],[24.093028,-38.880202],[24.948366,-39.997606],[26.082428,-40.869602],[27.404631,-41.415731],[28.800000,-41.597773],[30.195369,-41.415731],[31.517571,-40.869602],[32.651634,-39.997606],[33.506972,-38.880202],[34.047003,-37.580755],[34.235143,-36.162630],[34.235143,-36.162630]]);
}

module poly_path4335(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      polygon([[-23.364857,-36.162630],[-23.552997,-34.744506],[-24.093028,-33.445059],[-24.948367,-32.327655],[-26.082429,-31.455658],[-27.404631,-30.909530],[-28.800000,-30.727487],[-30.195370,-30.909530],[-31.517572,-31.455658],[-32.651634,-32.327655],[-33.506972,-33.445059],[-34.047003,-34.744506],[-34.235143,-36.162630],[-34.047003,-37.580755],[-33.506972,-38.880202],[-32.651634,-39.997606],[-31.517572,-40.869602],[-30.195369,-41.415731],[-28.800000,-41.597773],[-27.404631,-41.415731],[-26.082429,-40.869602],[-24.948366,-39.997606],[-24.093028,-38.880202],[-23.552997,-37.580755],[-23.364857,-36.162630],[-23.364857,-36.162630]]);
}

module poly_path4333(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      polygon([[34.235143,39.437367],[34.047003,40.855492],[33.506972,42.154939],[32.651633,43.272343],[31.517571,44.144339],[30.195369,44.690468],[28.800000,44.872510],[27.404630,44.690468],[26.082428,44.144339],[24.948366,43.272343],[24.093028,42.154939],[23.552997,40.855492],[23.364857,39.437367],[23.552997,38.019243],[24.093028,36.719796],[24.948366,35.602392],[26.082428,34.730395],[27.404631,34.184267],[28.800000,34.002224],[30.195369,34.184267],[31.517571,34.730395],[32.651634,35.602392],[33.506972,36.719796],[34.047003,38.019243],[34.235143,39.437367],[34.235143,39.437367]]);
  
}

module poly_path4927(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      {polygon([[-17.399561,-45.667002],[-17.399561,-27.787767],[-25.619901,-27.787767],[-25.619901,-19.567432],[-33.401680,-19.567432],[-33.401680,11.820278],[-25.414392,11.820278],[-25.414392,21.917738],[-14.727951,21.917738],[-14.727951,29.110528],[14.454252,28.905028],[14.419342,22.077538],[25.346201,22.077538],[25.346201,8.559688],[28.812301,8.559688],[28.812301,-16.512342],[25.551712,-16.512342],[25.551712,-27.582257],[17.125865,-27.582257],[17.125865,-45.872510]]);
 
      *polygon([[-17.399561,-44.667002],[-17.399561,-26.787767],[-25.619901,-26.787767],[-25.619901,-18.567432],[-32.401680,-18.567432],[-32.401680,10.820278],[-25.414392,10.820278],[-25.414392,21.917738],[-14.727951,21.917738],[-14.727951,29.110528],[14.454252,28.905028],[14.419342,22.077538],[25.346201,22.077538],[25.346201,8.559688],[27.812301,8.559688],[27.812301,-16.512342],[25.551712,-16.512342],[25.551712,-26.582257],[17.125865,-26.582257],[17.125865,-44.872510]]);
  }
}

module poly_path4919(h)
{
  scale([25.4/90, -25.4/90, 1]) union()
      polygon([[-23.364857,39.437367],[-23.552997,40.855492],[-24.093028,42.154939],[-24.948367,43.272343],[-26.082429,44.144339],[-27.404631,44.690468],[-28.800000,44.872510],[-30.195370,44.690468],[-31.517572,44.144339],[-32.651634,43.272343],[-33.506972,42.154939],[-34.047003,40.855492],[-34.235143,39.437367],[-34.047003,38.019243],[-33.506972,36.719796],[-32.651634,35.602392],[-31.517572,34.730395],[-30.195369,34.184267],[-28.800000,34.002224],[-27.404631,34.184267],[-26.082429,34.730395],[-24.948366,35.602392],[-24.093028,36.719796],[-23.552997,38.019243],[-23.364857,39.437367],[-23.364857,39.437367]]);
  
}

module joyholes(){
translate([0,-1.65,0])scale([1.25,1.25,1]){
union(){
//translate([0,-11.7])#square([8,1.75],center=true);
poly_path4925(0);
poly_path4287(0);
poly_path4921(0);
poly_path4923(0);
poly_path4337(0);
poly_path4335(0);
poly_path4333(0);
poly_path4927(0);
poly_path4919(0);
}}}
