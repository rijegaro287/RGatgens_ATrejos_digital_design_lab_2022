module video_controller 
#(
	parameter WIDTH = 640,
	parameter HEIGHT = 480,
	parameter ROWS = 10,
	parameter COLS = 10
)
(
	input logic clock,
	input logic [1:0] state,
	input logic [(ROWS-1):0][(COLS-1):0] grid,

	output logic h_synq,
	output logic v_synq,
	output logic [7:0] red,
	output logic [7:0] green,
	output logic [7:0] blue,
	output logic clk_25mhz,
	output logic sync_n,
	output logic blank_n
);
	/* DIMENSIONES DE LAS CELDAS	 */
	localparam CELL_WIDTH = WIDTH / COLS;
	localparam CELL_HEIGHT = HEIGHT / ROWS;
	
	/* COLORES */
	localparam SNAKE_R = 8'h63;
	localparam SNAKE_G = 8'hA3;
	localparam SNAKE_B = 8'h56;

	localparam GRASS_R = 8'h00;
	localparam GRASS_G = 8'h00;
	localparam GRASS_B = 8'h00;
	
	// VGA variables de control 
	logic enable_v_counter;
	logic [15:0] h_count_value;
	logic [15:0] v_count_value;

	// Clock divider
	clock_divider vga_clock_gen(clock, clk_25mhz);
	
	// Counters
	horizontal_counter vga_horizontal (clk_25mhz, enable_v_counter, h_count_value);
	vertical_counter vga_Vertical (clk_25mhz, enable_v_counter, v_count_value);
	
	// vertical y horizontal sync basados en los estandares 
	assign h_synq = (h_count_value < 96) ? 1'b1 : 1'b0;
	assign v_synq = (v_count_value < 2) ? 1'b1 : 1'b0;
	
	always begin
		// draw_game_screen();/*  */
		case (state)
			2'b01: draw_game_screen();
			// 2'b10: draw_win_screen();
			// 2'b11: draw_game_over_screen();
			default: draw_diff_selection_screen();
		endcase
	end

	assign sync_n = 1'b0;
	assign blank_n = 1'b1;

	task draw_game_screen;
		for (int i = 0; i < ROWS; i++) begin
			for (int j = 0; j < COLS; j++) begin
				if (v_count_value >= (i * CELL_HEIGHT + 35) && v_count_value < ((i+1) * CELL_HEIGHT + 35) &&
						h_count_value >= (j * CELL_WIDTH + 144) && h_count_value < ((j+1) * CELL_WIDTH + 144)
				) begin
					if(grid[i][j]) begin
						red <= SNAKE_R;
						green <= SNAKE_G;
						blue <= SNAKE_B;
					end
					else begin
						red <= GRASS_R;
						green <= GRASS_G;
						blue <= GRASS_B;	
					end 
				end
			end
		end
	endtask

	task draw_diff_selection_screen;
		if (v_count_value >= 35 && v_count_value < 515 &&
				h_count_value >= 144 && h_count_value < 784
		) begin
			red <= GRASS_R;
			green <= GRASS_G;
			blue <= GRASS_B;	
		end
	endtask

	task draw_win_screen;

	endtask

	task draw_game_over_screen;

	endtask
endmodule
