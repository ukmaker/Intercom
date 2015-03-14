// Revision B of the Intercom box
//
// Relies on using button extenders so the PCB can be 
// attached to the backplate and multiple levels are not needed
// 

// All dimensions in mm

// nice round holes
$fs=0.01;

// kerf of the laser beam
kerf = 0.2;
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
spi_connector_bottom_y = 35;
spi_connector_left_x = 55;
spi_connector_width = 5;
spi_connector_height = 8;
spi_connector_base_t = 2;
spi_connector_pin_t = 8;
spi_connector_pin_w = 0.8;

microphone_x = 91.0;
microphone_y = 63.0;
microphone_dia = 8;
microphone_t = 5;

tenth_in = 2.54;

top_panel_t = 4;
top_panel_h = 110;
top_panel_w = 110;

tongue_length = 20;
tongue_depth = 4;

box_h = btn_ext_t 
	+ 1 * top_panel_t 
	+ btn_base_t + btn_rim_t
	+ pcb_t 
	+ spi_connector_pin_t;


base_z = -spi_connector_pin_t;// - top_panel_t;

module button(x, y, z, c) {

	// the base on the PCB
	color("Black")
	translate([x-btn_base_w/2, y-btn_base_h/2, z])
	cube([btn_base_w, btn_base_h, btn_base_t]);

	// the stalk
	color("White")
	translate([x-btn_ext_w/2, y-btn_ext_h/2, z + btn_base_t])
		cube([btn_ext_w,btn_ext_h,btn_ext_t]);

	color(c) {
		// the rim at the base of the cap
		translate([x,y,z+btn_base_t+btn_ext_t])
			cylinder(r=btn_rim_dia/2, h=btn_rim_t);

		translate([x,y, z+btn_base_t+btn_ext_t+btn_rim_t])
			cylinder(r=btn_body_dia/2, h=btn_body_t);
	}

}

module button_hole(x,y) {
		translate([x,y, pcb_t+btn_base_t+btn_ext_t+btn_rim_t])
			cylinder(r=btn_hole_dia/2, h=top_panel_t+skerf);
}

module pcb() {

	color("Red")
		cube([pcb_w, pcb_h, pcb_t]);
	
	translate([speaker_x, speaker_y,  pcb_t])
		color("Black")
		cylinder(r=speaker_dia/2, h=0.01);
}

module speaker_hole() {
	translate([speaker_x, speaker_y, pcb_hole_z])
		cylinder(r=speaker_inner_dia/2, h=pcb_hole_t);
}

module mounting_hole(x, y) {
	translate([x,y,pcb_hole_z])
	cylinder(r=pcb_mth_dia/2, h=pcb_hole_t);
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

module microphone(x,y) {
	
	color("Silver")
	translate([x,y,pcb_t])
		cylinder(r=microphone_dia/2, h=microphone_t);
	color("Black")
	translate([x,y,pcb_t+microphone_t])
		cylinder(r=microphone_dia/2 - 1, h=0.2);
}

module mounting_holes() {
		mounting_hole(pcb_mth_x,                   pcb_mth_y);
		mounting_hole(pcb_mth_x+pcb_mth_x_spacing, pcb_mth_y);
		mounting_hole(pcb_mth_x+pcb_mth_x_spacing, pcb_mth_y+pcb_mth_y_spacing);
		mounting_hole(pcb_mth_x,                   pcb_mth_y+pcb_mth_y_spacing);
}

module pcb_assembly() {

	difference() {
		pcb();
		speaker_hole();
		mounting_holes();
	}

	button(pcb_btn_x,                      pcb_btn_y, pcb_t, "Blue");
	button(pcb_btn_x + pcb_btn_x_spacing,  pcb_btn_y, pcb_t, "Red");
	button(pcb_btn_x + pcb_btn_x_spacing*2,pcb_btn_y, pcb_t, "Yellow");
	button(pcb_btn_x + pcb_btn_x_spacing*3,pcb_btn_y, pcb_t, "Green");
	button(pcb_btn_x + pcb_btn_x_spacing*4,pcb_btn_y, pcb_t, "Black");

	spi_connector();

	microphone(microphone_x, microphone_y);
}

module top_microphone_hole(vec) {
	
	translate([vec[0]+microphone_x,vec[1]+microphone_y,pcb_t+btn_base_t+btn_ext_t+btn_rim_t])
		cylinder(r=0.5, h=top_panel_t+skerf);
}

module top_speaker_hole(vec) {
	
	translate([vec[0]+speaker_x,vec[1]+speaker_y,pcb_t+btn_base_t+btn_ext_t+btn_rim_t])
		cylinder(r=0.6, h=top_panel_t+skerf);
}

function point(radius, theta) =
 [radius * cos(theta), radius * sin(theta)];

module top_microphone_holes() {
	//color("Black")
	//	top_speaker_hole(pcb_speaker_x, pcb_speaker_y);

	for(s = [ [0,1], [4,8]]) {

		for(i = [0:1:s[1]-1]) {

			color("Black")
				top_microphone_hole(point(s[0], i*360/s[1]));
		}
	}
}

module top_speaker_holes() {
	//color("Black")
	//	top_speaker_hole(pcb_speaker_x, pcb_speaker_y);

	for(s = [ [0,1], [5,8], [10, 16], [15, 24], [20, 32]]) {

		for(i = [0:1:s[1]-1]) {

			color("Black")
				top_speaker_hole(point(s[0], i*360/s[1]));
		}
	}
}

module top_bottom() {
	cube([top_panel_w, top_panel_h, 4]);
	
	translate([-tongue_depth,tongue_length,0])
		cube([tongue_depth,tongue_length,4]);
	
	translate([-tongue_depth,top_panel_h - 2*tongue_length,0])
		cube([tongue_depth,tongue_length,4]);
	
	translate([top_panel_w,tongue_length,0])
		cube([tongue_depth,tongue_length,4]);
	
	translate([top_panel_w,top_panel_h - 2*tongue_length,0])
		cube([tongue_depth,tongue_length,4]);
}

module left_right() {
	
	// basic panel
	cube();

	// add the 
	
}

module top_panel() {
	
	difference() {
		color("Pink", 0.5)
		translate([-5,-5,pcb_t+btn_base_t+btn_ext_t+btn_rim_t])
			top_bottom();

		button_hole(pcb_btn_x,                      pcb_btn_y);
		button_hole(pcb_btn_x + pcb_btn_x_spacing,  pcb_btn_y);
		button_hole(pcb_btn_x + pcb_btn_x_spacing*2,pcb_btn_y);
		button_hole(pcb_btn_x + pcb_btn_x_spacing*3,pcb_btn_y);
		button_hole(pcb_btn_x + pcb_btn_x_spacing*4,pcb_btn_y);

		top_microphone_holes();
		top_speaker_holes();
	}
}
module bottom_panel() {
	translate([-5,-5,base_z])
		top_bottom();
}
echo ("WIBBLE");
//top_panel();
//bottom_panel();
////pcb_assembly();
left_right();
