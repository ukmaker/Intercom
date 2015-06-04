/**
* Intercom box rev c
* This time I might get it right.
*
* Define all panels in 2d.
* Use extrude to render in 3D to show assembly
* 2D layout can be exported to SVG for laser-cutting
**/
// Relies on using button extenders so the PCB can be 
// attached to the backplate and multiple levels are not needed
// 

// All dimensions in mm

// nice round holes
$fs=0.01;

c=5;

// kerf of the laser beam
kerf = 0;//0.2;
skerf = kerf / 2;

// Let's have a nice picture of the PCB to we can see what's going on
pcb_w = 100;
pcb_h = 100;
pcb_t = 2;
pcb_hole_t = 2.2;
pcb_hole_z = -0.1;

pcb_mth_x = 3.7;
pcb_mth_y = 3.7;
pcb_mth_x_spacing = 92.4;
pcb_mth_y_spacing = 92.7;
pcb_mth_dia = 3.0;
pcb_b_clearance = 10;
pcb_l_clearance = 5;
pcb_r_clearance = 5;
pcb_t_clearance = 10;

pcb_btn_x_spacing = 17.15;
// position of first button (is this right?)
pcb_btn_x = 15.5;
pcb_btn_y = 6.1;

btn_body_dia = 11.5;
btn_hole_dia = 12 - skerf;
btn_body_t = 4.5;

btn_rim_dia = 13;
btn_rim_t = 1.5;

btn_base_w = 10;
btn_base_h = 10;
btn_base_t = 3;
btn_ext_w = 8;
btn_ext_h = 8;
btn_ext_t = 18;


speaker_dia = 50;
speaker_inner_dia = 22;

speaker_x = 30;
speaker_y = 68;

spi_connector_top_y = 53;
spi_connector_bottom_y = 40;
spi_connector_left_x = 60;
spi_connector_width = 5;
spi_connector_height = 8;
spi_connector_base_t = 2;
spi_connector_pin_t = 8;
spi_connector_pin_w = 0.8;
spi_hole_w = 9;
spi_hole_h = 15;
spi_hole_x = 58;
spi_hole_y = 36;

microphone_x = 91.0;
microphone_y = 63.0;
microphone_dia = 8;
microphone_t = 5;

tenth_in = 2.54;
thickness = 4;

top_panel_t = 4;
top_panel_h = pcb_h + pcb_b_clearance + pcb_t_clearance;
top_panel_w = pcb_w + pcb_r_clearance + pcb_l_clearance + 2 * thickness;


tongue_length = 20;
tongue_depth = thickness;

box_h = btn_ext_t 
	+ 1 * top_panel_t 
	+ btn_base_t + btn_rim_t
	+ pcb_t 
	+ spi_connector_pin_t;


base_z = -spi_connector_pin_t;// - top_panel_t;

top_bottom_gap = pcb_t+btn_base_t+btn_ext_t+btn_rim_t + spi_connector_pin_t;
side_panel_h = top_bottom_gap + 2*top_panel_t;

side_panel_tongue_offset = 
  ((side_panel_h - 2*top_panel_t) - tongue_length) / 2;

side_panel_ul_groove_xy = 
  (side_panel_h - tongue_length) / 2;

ul_panel_h = side_panel_h - 2 * top_panel_t;

// Top-level 2D modules
// The PCB mounting holes
// A separate module since we need them on the bottom box plate as well
module mounting_holes() {
		mounting_hole(pcb_mth_x,                   pcb_mth_y);
		mounting_hole(pcb_mth_x+pcb_mth_x_spacing, pcb_mth_y);
		mounting_hole(pcb_mth_x+pcb_mth_x_spacing, pcb_mth_y+pcb_mth_y_spacing);
		mounting_hole(pcb_mth_x,                   pcb_mth_y+pcb_mth_y_spacing);
}

module mounting_hole(x, y) {
	translate([x,y,0])
	circle(r=pcb_mth_dia/2);
}

// The PCB with the speaker outline and hole
module pcb() {

	difference() {
        square([pcb_w, pcb_h]);
		translate([speaker_x, speaker_y,  0]) color("Blue") speaker_hole();
        mounting_holes();
    }

    // a circle to show where the speaker goes
    color("Black")
	translate([speaker_x, speaker_y,  0]) {
        difference() {
            circle(r=speaker_dia/2);
            circle(r=(speaker_dia/2)-1);
        }
    }
    
    // a circle to show where the microphone goes
    	
	color("Black")
	translate([microphone_x,microphone_y,0]) {
        difference() {
            circle(r=microphone_dia/2);
            circle(r=(microphone_dia/2)-1);
        }
    }
}

module speaker_hole() {
		circle(r=speaker_inner_dia/2);
}

module tongue() {
    square([tongue_length, tongue_depth]);
}

module spi_connector() {

	translate([spi_connector_left_x, spi_connector_bottom_y, -spi_connector_base_t])
	color("black")
	cube([spi_connector_width, spi_connector_height, spi_connector_base_t]);
	color("Gold") {
		// the pins
		spi_pin(spi_connector_left_x,          spi_connector_bottom_y);
		spi_pin(spi_connector_left_x+tenth_in, spi_connector_bottom_y);

		spi_pin(spi_connector_left_x,          spi_connector_bottom_y+tenth_in);
		spi_pin(spi_connector_left_x+tenth_in, spi_connector_bottom_y+tenth_in);

		spi_pin(spi_connector_left_x,          spi_connector_bottom_y+2*tenth_in);
		spi_pin(spi_connector_left_x+tenth_in, spi_connector_bottom_y+2*tenth_in);

	}
}

module spi_pin(x,y) {
	translate([x+1,y+1,-spi_connector_pin_t])
		cube([spi_connector_pin_w, spi_connector_pin_w, spi_connector_pin_t]);
}

// The blank for the top or bottom
module top_bottom() {
    
    square([top_panel_w, top_panel_h]);
	
	translate([tongue_length,-tongue_depth,0])
		tongue();
	
	translate([top_panel_w-2*tongue_length, -tongue_depth,0])
		tongue();
	
	translate([tongue_length,top_panel_h,0])
		tongue();
	
	translate([top_panel_w-2*tongue_length, top_panel_h,0])
		tongue();
	
}

module bottom() {
    difference() {
		translate([-(pcb_l_clearance + thickness),-(pcb_b_clearance+thickness),0]) 
        top_bottom();
        mounting_holes();
        spi_hole();
    }
}


module spi_hole() {
    translate([spi_hole_x, spi_hole_y,0])
    square([spi_hole_w, spi_hole_h]);
}

module top_microphone_hole(vec) {
	
	translate([vec[0]+microphone_x,vec[1]+microphone_y,0])
		circle(r=0.5);
}

module top_speaker_hole(vec) {
	
	translate([vec[0]+speaker_x,vec[1]+speaker_y,0])
		circle(r=0.6);
}

function point(radius, theta) =
 [radius * cos(theta), radius * sin(theta)];

module top_microphone_holes() {
	for(s = [ [0,1], [4,8]]) {

		for(i = [0:1:s[1]-1]) {
            top_microphone_hole(point(s[0], i*360/s[1]));
		}
	}
}

module top_speaker_holes() {
	for(s = [ [0,1], [5,8], [10, 16], [15, 24], [20, 32]]) {

		for(i = [0:1:s[1]-1]) {
            top_speaker_hole(point(s[0], i*360/s[1]));
		}
	}
}

module button_hole(x,y) {
    translate([x,y,0]) circle(r=btn_hole_dia/2);
}

module button_holes() {
    button_hole(pcb_btn_x + pcb_btn_x_spacing*0,pcb_btn_y);
    button_hole(pcb_btn_x + pcb_btn_x_spacing*1,pcb_btn_y);
    button_hole(pcb_btn_x + pcb_btn_x_spacing*2,pcb_btn_y);
    button_hole(pcb_btn_x + pcb_btn_x_spacing*3,pcb_btn_y);
    button_hole(pcb_btn_x + pcb_btn_x_spacing*4,pcb_btn_y);
}

module top_holes() {
    button_holes();
    top_microphone_holes();
    top_speaker_holes();
}

module top() {
	
	difference() {
		translate([-(pcb_l_clearance + thickness),-(pcb_b_clearance+thickness),0]) 
        top_bottom();
        top_holes();
	}
}

module upper_lower() {
	
    difference() {
        // basic upper or lower panel
        square([top_panel_w, side_panel_h]);
        
        upper_lower_grooves();

        // Remove the tongues at the left and right
        translate([0, side_panel_ul_groove_xy, 0])
          groove_l();
        
        translate([top_panel_w-tongue_depth, side_panel_ul_groove_xy,0])
          groove_r();
	}
}

module upper_lower_grooves() {
    // remove the lower grooves
    translate([tongue_length,0,0])
       groove_b();
    
    translate([top_panel_w-2*tongue_length,0])
        groove_b();

 
    // remove the upper grooves
    translate([tongue_length,side_panel_h-tongue_depth,0])
       groove_t();
    
    translate([top_panel_w-2*tongue_length,side_panel_h-tongue_depth,0])
        groove_t();

 
}

module groove_l() {
    remove_l(tongue_depth,tongue_length);
}
module groove_r() {
    remove_r(tongue_depth,tongue_length);
}

module groove_t() {
    remove_t(tongue_length,tongue_depth);
}
module groove_b() {
    remove_b(tongue_length,tongue_depth);
}

module remove_l(w,h) {
    // actual shape needs to be smaller by the amount of kerf
    // and moved to leave space for the kerf
    translate([-skerf,skerf,0])
    square([w+kerf,h-kerf]);
}

module remove_r(w,h) {
    // actual shape needs to be smaller by the amount of kerf
    // and moved to leave space for the kerf
    translate([skerf,skerf,0])
    square([w+kerf,h-kerf]);
}

module remove_t(w,h) {
    // actual shape needs to be smaller by the amount of kerf
    // and moved to leave space for the kerf
    translate([skerf,skerf,0])
    square([w-kerf,h+kerf]);
}

module remove_b(w,h) {
    // actual shape needs to be smaller by the amount of kerf
    // and moved to leave space for the kerf
    translate([skerf,-skerf,0])
    square([w-kerf,h+kerf]);
}

module left_right() {
    square([ul_panel_h, top_panel_h]);
    
    translate([side_panel_tongue_offset,-tongue_depth, 0])
      tongue();
    translate([side_panel_tongue_offset,top_panel_h, 0])
      tongue();
}
 

//translate([0,0,-1]) bottom();
//pcb();
//translate([0,0,1]) top();

//left_right();

//upper_lower();

module perspex(alpha=1)
{
	h = thickness;
	color("White",alpha) 
        linear_extrude(height=h,convexity=c,center=true) 
            for (i = [0 : $children-1]) children(i);
}

module assembled() {

    translate([0,0,spi_connector_pin_t]) {
        color("Red") pcb();
        spi_connector();
    }
    
    translate([0,0,thickness/2]) perspex() bottom();
    translate([0,0,top_bottom_gap + 1.5*thickness]) perspex() top();
    
    #color("Green")
    translate([-(thickness/2 + pcb_l_clearance), -(pcb_b_clearance + thickness),thickness])
        rotate([0,-90,0])
        perspex() left_right();

    color("Green")
    translate([top_panel_w -(thickness/2 + pcb_l_clearance + thickness), -(pcb_b_clearance+thickness),thickness])
        rotate([0,-90,0])
        perspex() left_right();

    color("Blue")   
    translate([-(thickness + pcb_l_clearance), -(pcb_b_clearance+3/2*thickness),0])    
    rotate([90,0,0])    
    perspex() upper_lower();

    color("Blue")   
    translate([-(thickness + pcb_l_clearance), top_panel_h-(pcb_b_clearance+3/2*thickness)+thickness,0])    
    rotate([90,0,0])    
    perspex() upper_lower();

}

module outlines() {
    bottom();
    translate([130,0,0]) top();
    
    translate([250,-14,0]) left_right();
    translate([290,-14,0]) left_right();
    translate([-9,-65,0]) upper_lower();
    translate([121,-65,0]) upper_lower();
    
    translate([0,-100,0]) {
        color("Black")
        difference() {
            square([100,20]);
            translate([0,5,0]) text("100mm x 20mm");
        }
    }
}

module stacked() {
    perspex() bottom();
    color("Red") translate([0,0,thickness+1]) perspex() pcb();
    color("Pink") translate([0,0,2*(thickness+1)]) perspex() top();
}

//stacked();
assembled();
//outlines();