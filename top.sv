module top
# (
    parameter clk_mhz       = 50,
              pixel_mhz     = 25,

              w_key         = 2,
              w_sw          = 10,
              w_led         = 10,
              w_digit       = 6,
              w_gpio        = 36,

              screen_width  = 640,
              screen_height = 480,

              w_red         = 4,
              w_green       = 4,
              w_blue        = 4,

              w_x           = $clog2 ( screen_width  ),
              w_y           = $clog2 ( screen_height ),

              w_arduino     = 16
)
(
    input                     MAX10_CLK1_50,

    input  [ w_key     - 1:0] KEY,
    input  [ w_sw      - 1:0] SW,
    output [ w_led     - 1:0] LEDR,

    output logic        [7:0] HEX0,
    output logic        [7:0] HEX1,
    output logic        [7:0] HEX2,
    output logic        [7:0] HEX3,
    output logic        [7:0] HEX4,
    output logic        [7:0] HEX5,

    output                    VGA_HS,
    output                    VGA_VS,
    output [ w_red     - 1:0] VGA_R,
    output [ w_green   - 1:0] VGA_G,
    output [ w_blue    - 1:0] VGA_B,

    inout  [ w_gpio    - 1:0] GPIO,

    output                    ARDUINO_RESET_N,
    inout  [ w_arduino - 1:0] ARDUINO_IO
);
    wire       clk = MAX10_CLK1_50;
    wire       rst = SW[9];
    wire [8:0] sw  = SW[8:0];
    wire [1:0] key = ~KEY[1:0];
    wire [9:0] led;
    assign LEDR = led;

    localparam 
        SFLEN     = 32,
        SExpWidth = 8,
        SSigWidth = 24,
        
        DFLEN     = 64,
        DExpWidth = 11,
        DSigWidth = 53,

        FLEN     = SFLEN,
        ExpWidth = SExpWidth,
        SigWidth = SSigWidth,

        RECLEN   = FLEN+1
    ;

    logic [FLEN-1:0] arg_a, arg_b;

    always_ff @ (posedge clk)
        if (rst) begin
            arg_a <= '0;
            arg_b <= '0;
        end
        else if (key[1])
        begin
            arg_a <= { arg_a[FLEN-2:0], sw[1] };
            arg_b <= { arg_b[FLEN-2:0], sw[2] };
        end

    wire [FLEN-1:0] result;

    wire [RECLEN-1:0] record_a, record_b, record_add, record_mult;

    fNToRecFN #(.expWidth(ExpWidth), .sigWidth(SigWidth))
    inst_a (
        .in  (arg_a),
        .out (record_a)
    );

    fNToRecFN #(.expWidth(ExpWidth), .sigWidth(SigWidth))
    inst_b (
        .in  (arg_b),
        .out (record_b)
    );

    mulAddRecFN #(.expWidth(ExpWidth), .sigWidth(SigWidth))
    inst_multadd (
        .control        ( 0 ),
        .a              ( record_a ),
        .b              ( record_b ),
        .c              ( record_b ),
        .roundingMode   ( `round_near_even ),
        .out            ( record_add ),
        .exceptionFlags ( HEX0 )
    );

    recFNToFN #(.expWidth(ExpWidth), .sigWidth(SigWidth))
    inst_res (
        .in  (record_add),
        .out (result)
    );

    assign led = result;

endmodule
