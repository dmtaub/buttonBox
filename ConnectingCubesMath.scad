$fs=.1;


radius = 8/2;
hole_radius = 8.2/2;//radius + 0.2;
height = 15;
side = 19;


difference(){
  union(){
    cube([side, side, side], center=true);
    difference(){
      cylinder(r1=radius, r2=radius, h=height, center=false);
    }
  }
  union(){
            translate([0,0,-height+0.1])cylinder(r1=radius/2, r2=radius/2, h=height*2, center=false);
    translate([0, 0, -height]){
      cylinder(r1=hole_radius, r2=hole_radius, h=height, center=false);

    }
    for (i = [1 : abs(1) : 4]) {
      rotate([0, 90, (90 * i)]){
        translate([0, 0, -height]){
          cylinder(r1=hole_radius, r2=hole_radius, h=height, center=false);
        }
      }
    }
  }
}