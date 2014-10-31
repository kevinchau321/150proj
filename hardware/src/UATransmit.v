module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);



  //--|Solution|----------------------------------------------------------------

  //++++Declarations++++//
  wire SymbolEdge;
  wire Sample;
  wire Start;
  wire TXRunning;
  
  reg SOutReg;
//  reg sentByte;
  reg [9:0] TXShift;
  reg [3:0] BitCounter;
  reg [ClockCounterWidth-1:0] ClockCounter;

  //++++Signals++++//
 
  assign SymbolEdge = (ClockCounter == SymbolEdgeTime - 1);
  assign TXRunning = (BitCounter != 4'b0);
  assign DataInReady = ~TXRunning; // ANDREW: Changed second expression from DataInValid
  assign SOut = SOutReg;
   assign Start = DataInValid;
 //&& ~TXRunning && ~Reset;

  always @ (posedge Clock) begin
	ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end

  always @ (posedge Clock) begin
     if (Reset) begin
	BitCounter <= 0;
     end
     else if (Start) begin
	BitCounter <= 10;
     end
     else if (SymbolEdge && TXRunning)
	BitCounter <= BitCounter - 1;
  end

  /* always @(posedge Clock) begin
      if (Reset) sentByte <= 1'b0;
      else if (BitCounter == 1 && SymbolEdge) sentByte <= 1'b1;
      else if (DataInValid) sentByte <= 1'b0;
   end*/ // Why do I have to separate the extra states of each changing register?

  always @ (posedge Clock) begin
	if (Reset) begin
	   SOutReg <= 1'b1;
	end
	else if (Start) begin
	   TXShift <= {1'b1,DataIn,1'b0};
	end else if (SymbolEdge && TXRunning) begin
	   SOutReg <= TXShift[0];
	   TXShift <= TXShift >> 1;
        end // else if (TXShift == 10'b0000000000 && ~TXRunning)
	    // SOutReg <= 1'b1;
  end

endmodule
