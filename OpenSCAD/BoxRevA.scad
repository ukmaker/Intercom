// Stackup
//
//  -------------------------
//  ----- Top Panel ---------
//         __               |
//        |  |              |----- Button Panel ------------------
//        |CP|                                    |LED| |Button|
//  --------------------PCB---------------------------------------
//    || ----------Isolation ------------------------------------------ 
//    ||  _______________________     ----\         /---Speaker Holder
//	   || |                       |     ||  \-------/  ||
//    || | Battery               |     ||     Speaker ||
//    || |                       |     ||             ||
//  ------------ baseplate ---------------------------------------
panel_thickness = 4.0;
$fs=0.01;
mounting_hole_x_spacing = 92.4;
mounting_hole_y_spacing = 92.7;

button_x_spacing = 17.15;

board_to_mth_y = 3.7;
board_to_mth_x = 3.7;
board_to_button_y = 6.1;
board_to_led_y = 15.6;

led_dia = 5.0;
button_dia = 11.5;

num_buttons = 5;
num_leds = 5;

electrolytic_height = 18.0;
button_rim_height = 8.0;
speaker_dia = 50.0;

speaker_hole_y = 68;
speaker_hole_x = 30;
spi_connector_top_y = 53;
spi_connector_bottom_y = 35;
spi_connector_left_x = 55;
spi_connector_width = 10;
spi_connector_height = 15;
board_size = 100;

battery_height = 18;
lead_clearance_height = 3;
pcb_thickness = 1.5;

bottom_clearance_height = battery_height + lead_clearance_height + panel_thickness + pcb_thickness;

baseplate_length = board_size + 2 + button_dia/2 + 2 * panel_thickness;
panel_length = board_to_led_y + led_dia*2 + button_dia/2;

body_thickness = 5.0;

microphone_x = 91.0;
microphone_y = 63.0;

drill_x_offset = (board_size - button_x_spacing * (num_buttons-1)) / 2;

module leds() 
{

	for(x=[0:1:num_leds-1]) {

		translate([	drill_x_offset + x*button_x_spacing, 
						board_to_led_y,
						bottom_clearance_height + button_rim_height-0.1])
 
			cylinder(r=led_dia/2 + 0.1, h=panel_thickness+0.2);
	}
}

module buttons() 
{

	for(x=[0:1:num_buttons-1]) {

		translate([	drill_x_offset + x*button_x_spacing, 
						board_to_button_y,
						bottom_clearance_height + button_rim_height-0.1])
 
			cylinder(r=button_dia/2 + 0.1, h=panel_thickness+0.2);
	}
}

module button_panel() {
	translate([0, -button_dia/2,bottom_clearance_height + button_rim_height])
		cube([board_size + 2, panel_length, panel_thickness]);
}

module drilled_panel() {
	difference() {
		button_panel();
		#leds();
		#buttons();
	}
}

module top_plate() {
	translate([0,panel_length - button_dia/2,bottom_clearance_height + electrolytic_height])
	cube([board_size+2, baseplate_length - panel_length, panel_thickness]);
}

module speaker_holes() {

	for(x=[0:1:6]) {
		for(y=[0:1:6]) {
			translate([10 + 5*x, 50 + 5*y, bottom_clearance_height + electrolytic_height-0.1])
			cylinder(r=1,h=panel_thickness+0.2);
		}
	}
}

module microphone_holes() {

	for(x=[0:1:2]) {
		for(y=[0:1:2]) {
			translate([microphone_x + 3*(x-1), microphone_y + 3*(y-1), bottom_clearance_height + electrolytic_height-0.1])
			cylinder(r=0.5,h=panel_thickness+0.2);
		}
	}

}

module drilled_top_plate() {
	difference() {
		top_plate();
		#speaker_holes();
		#microphone_holes();
	}
}

module connector() {
	translate([0, panel_length-button_dia/2, bottom_clearance_height + button_rim_height])
	color("pink")
	cube([board_size+2, panel_thickness, electrolytic_height - button_rim_height]);
}

module side(x) {

	translate([x,-button_dia/2,0])
	color("blue") 
	cube([panel_thickness, panel_length+panel_thickness,bottom_clearance_height + button_rim_height]);

	translate([x, panel_length-button_dia/2 + panel_thickness, 0])
	color("green")
	cube([panel_thickness, 
			baseplate_length - panel_length - panel_thickness, 
			bottom_clearance_height + electrolytic_height]);
}

module front() {

	translate([panel_thickness, -button_dia/2,0])
	color("orange")
	cube([board_size+2 - 2*panel_thickness, 
			panel_thickness,
			bottom_clearance_height + button_rim_height]);
}

module back_flange() {
	difference() {
		color("orange")
		translate([panel_thickness, board_size+2,0])
		cube([
				board_size+2 - 2*panel_thickness, 
				panel_thickness, 
				bottom_clearance_height + electrolytic_height
		]);

		translate([3*panel_thickness, board_size+2,2*panel_thickness])
		#cube([
				board_size+2 - 6*panel_thickness, 
				panel_thickness, 
				bottom_clearance_height + electrolytic_height - 4 * panel_thickness
		]);
	}
}

module back() {
	translate([panel_thickness, board_size+2+panel_thickness,0])
	color("orange")
	cube([board_size+2 - 2*panel_thickness, panel_thickness, bottom_clearance_height + electrolytic_height]);
}

module base() {
	translate([0, -button_dia/2, -panel_thickness])
	cube([board_size+2, baseplate_length, panel_thickness]);
}

module mounting_holes() {
	
	translate([panel_thickness+0.1+board_to_mth_x,
		0.1+board_to_mth_y,
	-panel_thickness -0.1])

	cylinder(r=3.1/2,h=panel_thickness+0.2);

	translate([
		panel_thickness+0.1+board_to_mth_x + mounting_hole_x_spacing,
		0.1+board_to_mth_y,
		-panel_thickness - 0.1])

	cylinder(r=3.1/2,h=panel_thickness+0.2);

	translate([
		panel_thickness+0.1+board_to_mth_x + mounting_hole_x_spacing,
		0.1+board_to_mth_y + mounting_hole_y_spacing,
		-panel_thickness - 0.1])

	cylinder(r=3.1/2,h=panel_thickness+0.2);
	translate([
		panel_thickness+0.1+board_to_mth_x,
		0.1+board_to_mth_y + mounting_hole_y_spacing,
		-panel_thickness - 0.1])

	cylinder(r=3.1/2,h=panel_thickness+0.2);
}


module spi_connector_zone() {

	translate([spi_connector_left_x, spi_connector_bottom_y, 0])
	color("black")
	cube([spi_connector_width, spi_connector_height, panel_thickness]);
}

spi_connector_zone();


drilled_top_plate();
connector();
drilled_panel();

side(0);
side(board_size + 2 - panel_thickness);

front();
back_flange();
back();


difference() {
base();
mounting_holes();
}