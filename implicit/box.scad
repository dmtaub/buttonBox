
// truncated tetra buttonbox part maker by dmt
// based on mathgrrl polysnap tiles
// implicitcad optimized (extopenscad)

//////////////////////////////////////////////////////////////////////////
// PARAMETERS ////////////////////////////////////////////////////////////
$fn=50;

//test if openscad or implicit, and set angle accordingly;
fullcircle = (cos(180)==-1) ? 360 : 2*pi;
echo(fullcircle);
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
sphere_farout=-0.35; //was .fullcircle/8


// Set the border thickness, in mm
border = 3.5;	

/* [Adjust Fit] */

// Add extra space between snaps, in mm
clearance = 0.17;

// Add extra length to the snaps, in mm
lengthen = 0.3;


angle=fullcircle/4;


//////////////////////////////////////////////////////////////////////////
// MODULES ///////////////////////////////////////////////////////////////
module hinge_arm(BLOCKWIDTH,h_len,rad_o,clip){
  union(){
    translate([-clip,clip,0]){ cube([BLOCKWIDTH,h_len-clip,rad_o*2]);}
    //difference(){
    translate([BLOCKWIDTH-clip,h_len,rad_o]) {rotate([360/4,0,0]) {cylinder(r=rad_o,h=h_len-clip);} }
    //translate([-rad_o/2-clip,-clip,-clip]) {cube([BLOCKWIDTH/2,BLOCKWIDTH/3,rad_o*2+2*clip]);}
    //}
  }
}
module hinge_a(bw,hl,ro,cl,i){
  $res = 0.5;
  ri = ro/3;
  sri = ro/2 *1.7;
  if ( (i/2)-floor(i/2) == 0) {
    //if (i % 2 == 0){ 
    union(){     
      hinge_arm(bw,hl,ro,cl);
      //translate([bw,-farout,ro])sphere(r=sri,center=true);
      translate([bw,(hl-sri/4)+sphere_farout*sri,ro]){
        difference(){
          sphere(r=sri,center=true);
          translate([-0.05,-sri-sri*sphere_farout,-0.05]){cube(sri*2+0.1,center=true);}
        }}
    }

  }
  else{
    difference(){
      hinge_arm(bw,hl,ro,cl);
      translate([bw,hl+cl,ro]){rotate([360/4,0,0]){cylinder(h=hl+2*cl,r=ri*1.2);}}
    }
  }
  }


  //build the polygon shape of the tile
  //shape is made up of n=num_sides wedges that are rotated around
  module poly_maker(num_sides,radius,radiusa,thick,button_rad,line_thick, inner_circle_rad, line_length, translation, outter_rad, inside){
    echo(radiusa);
    echo(inside);
    //subtract the smaller polygon from the larger polygon
    difference(){
      //extrude to thicken the polygon
      linear_extrude(height=thickness,center=true){ 
        union(){
          //rotate the wedge n=num_sides times at angle of fullcircle/n each time
          for(i=[0:num_sides]){

            //rotation is around the z-axis [0,0,1]
            rotate([0,0,i*360/num_sides]){
              //make triangular wedge with angle based on number of num_sides
              polygon(

                  //the three vertices of the triangle
                  [[0-0.1,0-0.1], //tweaks fix CGAL errors
                  [radiusa,0-0.01],
                  [radiusa*cos(fullcircle/num_sides)-0.01,radiusa*sin(fullcircle/num_sides)+0.01]]);
            }
          }
        }
      }
      union(){
        //extrude to thicken the center polygon that will be the hole
        linear_extrude(height=thickness+2,center=true){ 

          //rotate the wedge n=num_sides times at angle of fullcircle/n each time			
          for(i=[0:num_sides]){

            //rotation is around the z-axis [0,0,1]
            rotate([0,0,i*360/num_sides])	

              //make triangular wedge with angle based on number of num_sides
              polygon(

                  //the three vertices of the triangle
                  [[0-0.2,0-0.2], //tweaks fix CGAL errors
                  [inside,0-0.01],
                  [inside*cos(fullcircle/num_sides)-0.01,inside*sin(fullcircle/num_sides)+0.01]]);
          }
        }
      }
    }
  }

  //build the snaps around the tile
  //try the commands alone with i=1 and i=2 to see how this works
  //remember to read from the bottom to the top to make sense of this
  module snap_maker(num_sides,radius, radiusa, snapwidth){
    union(){
      //rotate the side of snaps n=num_sides times at angle of fullcircle/n each time
      for(i=[0:num_sides-1]){ 
        //rotation is around the z-axis [0,0,1]
        rotate([0,0,i*360/num_sides]) 	{

          //build snaps for first side at the origin and move into positions
          for(j=[0:snaps-1]){	

            //read the rest of the commands from bottom to top
            //translate the snap to the first side
            translate([radius,0,-thickness/2]) {

              //rotate the snap to correct angle for first side
              rotate(180/num_sides) {

                //for i^th snap translate 2*i snapwidths over from origin
                translate([-thickness/2,2*(j+0.5)*snapwidth+clearance/2,0]) {
                  //cube(3.5); 
                  hinge_a(thickness/2+lengthen,snapwidth-clearance,thickness/2,0.01,j);
                }
              }
            }
          }
        }
      }
    }
  }



  module full_tile(num_sides, thick=5.5, button_rad=12.5, inner_circle_rad = 0){
    //radius depends on side length
    radius = side_length/(2*sin(fullcircle/2/num_sides)); 
    line_thick = border/1.5/(sin(fullcircle/2/num_sides)); // was 6
    radiusa=radius-(thickness/2/cos(fullcircle/2/num_sides));//-thickness/2;

    //inside radius depends on the border thickness
    inside = radiusa-border/(cos(fullcircle/2/num_sides)); 

    //width of each snap depends on number of snaps	-- magic formula :(
    //snapwidth = -(thickness/1.215)*sin(fullcircle/8)/snaps+side_length/2/snaps;
    //snapwidth = radiusa*sin(360/2/num_sides)/snaps;

    snapwidth = side_length/2/(snaps+1);

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
      /*translate([0,0,1])linear_extrude(height=thickness,center=true)
        for(i=[0:num_sides]){
      //rotation is around the z-axis [0,0,1]
      rotate([0,0,i*360/num_sides+angle]){translate([0,translation+inner_circle_offset])}
      circle(inner_circle_rad,center=true);
      }*/
    }
  }
  //////////////////////////////////////////////////////////////////////////
  // RENDERS ///////////////////////////////////////////////////////////////

  full_tile(6); 

  /*
     full_tile(3,thick=2.5, button_rad=2.5, inner_circle_rad = 0);
   */

  //thick=2.5; //tri
  //thick=5.5; // hex
  //button_rad=12.5; //hex
  //button_rad=2.5;//tri
  //line_thick = 4; //tri
  //line_thick = 6;

