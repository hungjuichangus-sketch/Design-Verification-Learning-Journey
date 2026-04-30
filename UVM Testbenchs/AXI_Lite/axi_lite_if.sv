interface axi_lite_if(input logic clk, rst_n);

    // ============================================================
    // WRITE ADDRESS CHANNEL (AW) - The "Where"
    // ============================================================
    logic [31:0] awaddr;  // The location the master wants to write to
    logic        awvalid; // Master: "The address I'm sending is valid"
    logic        awready; // Slave:  "I'm ready to receive this address"

    // ============================================================
    // WRITE DATA CHANNEL (W) - The "What"
    // ============================================================
    logic [31:0] wdata;   // The actual 32-bit data to be stored
    logic [3:0]  wstrb;   // Write Strobe: Which bytes in the 32-bit word to update
    logic        wvalid;  // Master: "The data I'm sending is valid"
    logic        wready;  // Slave:  "I'm ready to receive this data"

    // ============================================================
    // WRITE RESPONSE CHANNEL (B) - The "Receipt"
    // ============================================================
    logic [1:0]  bresp;   // The status of the write (e.g., 00 = OKAY)
    logic        bvalid;  // Slave:  "I'm sending a valid response back"
    logic        bready;  // Master: "I'm ready to accept your response"

    // ============================================================
    // READ ADDRESS CHANNEL (AR) - The "Query"
    // ============================================================
    logic [31:0] araddr;  // The location the master wants to read from
    logic        arvalid; // Master: "The read address is valid"
    logic        arready; // Slave:  "I'm ready to receive the read address"

    // ============================================================
    // READ DATA CHANNEL (R) - The "Answer"
    // ============================================================
    logic [31:0] rdata;   // The data the slave found at the address
    logic [1:0]  rresp;   // The status of the read (e.g., 00 = OKAY)
    logic        rvalid;  // Slave:  "The data I'm returning is valid"
    logic        rready;  // Master: "I'm ready to receive the data"

    // ============================================================
    // Driver Clocking Block (Master Perspective)
    // ============================================================
    clocking drv_cb @(posedge clk);
        default input #1step output #1ns;

        // AW Channel
        output awaddr, awvalid;
        input  awready;

        // W Channel
        output wdata, wstrb, wvalid;
        input  wready;

        // B Channel
        input  bresp, bvalid;
        output bready;

        // AR Channel
        output araddr, arvalid;
        input  arready;

        // R Channel
        input  rdata, rresp, rvalid;
        output rready;
    endclocking
endinterface
