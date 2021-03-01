
module cache(clk,data_cache_is_read_hit,data_cache_is_write_hit,data_cache_is_read,data_cache_read_address,data_cache_write_address,data_cache_data_in,data_cache_data_out,
            inst_cache_read_address,inst_cache_is_read_hit,inst_cache_inst_out);


input clk;                                                              // clock
reg [7:0] [15:0] main_memory[8191:0];                                   // 128 KB; 2^13 blocks,each block 8 words; each word 16 bit

/////////// data cache ////////////
input data_cache_is_read;                                               //port for selection of read mode or write mode; 1-read, 0-write
input [15:0] data_cache_read_address,                                   // address for reading
             data_cache_write_address,                                  // address for writing
             data_cache_data_in;                                        // data for writing

output reg [15:0] data_cache_data_out;                                  // read data from data cache
output reg data_cache_is_read_hit,                                      //output port for read hit or read miss; 1-read hit, 0-read miss
           data_cache_is_write_hit;                                     //output port for write hit or write miss; 1-write hit, 0-write miss

reg [7:0] [15:0] data_cache[2047:0];                                    // 32KB; 2^11=2048 no. of lines,each line 8 words,each word 16 bit

reg [1:0] data_cache_tag [2047:0];                                      // 2 bit tag for each line of data cache
reg [2047:0] data_cache_dirty ;                                         // dirty bit for each line of data cache; 1-dirty, 0-not dirty
reg [2047:0] data_cache_valid ;                                         // valid bit for each line of data cache; 1-valid, 0-not valid

reg [1:0] tag1;                                                         // to store 2 bit tag of requested address
reg [10:0] index1;                                                      // to store 11 bit index of requested address
reg [2:0] block_offset1;                                                // to store 3 bit block offset of requested address

reg [12:0] block_no1;                                                   // to store 13 bit block no.
////////////////////////////////////



//////// instruction cache /////////
input [15:0] inst_cache_read_address;                                   // address for reading
output reg inst_cache_is_read_hit;                                      //output port for read hit or read miss; 1-read hit, 0-read miss
output reg [15:0] inst_cache_inst_out;                                  // read data from data cache

reg [7:0] [15:0] inst_cache[1023:0];                                    //2048 no. of lines,each line 8 words,each word 16 bit

reg [1:0] inst_cache_tag [1023:0];                                      // 3 bit tag for each line of instruction cache
reg [1023:0] inst_cache_valid ;                                         // valid bit for each line of instruction cache; 1-valid, 0-not valid

reg [2:0] tag2;                                                         // to store 3 bit tag of requested address
reg [9:0] index2;                                                       // to store 10 bit index of requested address
reg [2:0] block_offset2;                                                // to store 3 bit block offset of requested address

reg [12:0] block_no2;                                                   // to store 13 bit block no.
///////////////////////////////////



initial
begin
  $readmemh("memory.txt", main_memory,0,8191);                          // memory.txt is file containing Main Memory which has 2^13 = 8192 lines , each line 8 words,
                                                                        // the memory is represented in hexadecimal format(0-f)
                                                                        // each word is 4 characters(16 bits) long hence each line contains 32 characters
                                                                        // readmemh loads the data from the file(memory.txt) into the variable(main_memory)
  data_cache_valid=2048'd0;                                             // initializing valid bits of data cache to 0(invalid)
  data_cache_dirty=2048'd0;                                             // initializing dirty bits of data cache to 0(not dirty)
  inst_cache_valid=1024'd0;                                             // initializing valid bits of instruction cache to 0(invalid)
end

//////////////////////////////////////////// Data Cache
always @ (posedge clk)
begin
	if(data_cache_is_read==1) ////// read
  	begin
      tag1=data_cache_read_address[15:14];                              // storing 2 bit tag of requested address
      index1=data_cache_read_address[13:3];                             // storing 11 bit index of requested address
      block_offset1=data_cache_read_address[2:0];                       // storing 3 bit block offset of requested address
		  if(data_cache_tag[index1]==tag1 && data_cache_valid[index1]==1)   // read hit if tag matches and the block is valid
		  begin
  			data_cache_is_read_hit=1;                                       // set data_cache_is_read_hit(read hit)
  			data_cache_data_out=data_cache[index1][block_offset1];          // getting data from cache from given index(line no.) and block offset
		  end
		  else //read miss
		  begin
		   data_cache_is_read_hit=0;                                        // clear data_cache_is_read_hit(read miss)
       if(data_cache_dirty[index1]==1)                                  // if dirty block then writing/replacing the dirty block into the main memory
           begin                                                        // a dirty block is a block that has not yet been made "permanent", by writing the block to main memory
             block_no1={data_cache_tag[index1],index1};                 // getting block no. of dirty block
             main_memory[block_no1]=data_cache[index1];                 // writing the dirty block into main memory
             $writememh("memory.txt",main_memory,0,8191);               // writememh loads the data from the variable(main_memory) into the file(memory.txt)
             data_cache_dirty[index1]=0;                                // clear dirty bit of the line
           end
        block_no1=data_cache_read_address[15:3];                        // block no. of requested address
     	  data_cache[index1]=main_memory[block_no1];                      // storing requested block to cache from main_memory
     	  data_cache_valid[index1]=1'b1;                                  // set valid bit of line
     	  data_cache_data_out=data_cache[index1][block_offset1];          // getting data from cache from given index(line no.) and block offset
        data_cache_tag[index1]=tag1;                                    // updating tag of line
		  end
  	end
  	else    /// write
  	begin
      tag1=data_cache_write_address[15:14];                             // storing 2 bit tag of requested address
      index1=data_cache_write_address[13:3];                            // storing 11 bit index offset of requested addres
      block_offset1=data_cache_write_address[2:0];                      // storing 3 bit block offset of requested address
		  if(data_cache_tag[index1]==tag1 && data_cache_valid[index1]==1)   // write hit if tag matches and the block is valid
		  begin
  		  	data_cache_is_write_hit=1;                                    // set data_cache_is_write_hit ( write hit )
  			  data_cache[index1][block_offset1]=data_cache_data_in;         // writing data into the given index(line no.) and block offset of the cache
  			  data_cache_dirty[index1]=1'b1;                                // set dirty bit of line
		  end
		  else //write miss
		  begin
        data_cache_is_write_hit=0;                                      // clear data_cache_is_write_hit(write miss)
        if(data_cache_dirty[index1]==1)                                 // if dirty block then writing/replacing the dirty block into the main memory
            begin
              block_no1={data_cache_tag[index1],index1};                // getting block no. of dirty block
              main_memory[block_no1]=data_cache[index1];                // block no. of requested address
              $writememh("memory.txt",main_memory,0,8191);              // writememh loads the data from the variable(main_memory) into the file(memory.txt)
              data_cache_dirty[index1]=0;                               // clear dirty bit of the line
            end
        block_no1=data_cache_write_address[15:3];                       // block no. of requested address
        data_cache[index1]=main_memory[block_no1];                      // storing requested block to cache from main_memory
        data_cache_valid[index1]=1'b1;                                  // set valid bit of line
        data_cache[index1][block_offset1]=data_cache_data_in;           // writing data into the given index(line no.) and block offset of the cache
        data_cache_dirty[index1]=1'b1;                                  // set dirty bit of line
        data_cache_tag[index1]=tag1;                                    // updating tag of line
		  end
  	end
end
/////////////////////////////////////////////

////////////////////////////////////////////////  instruction cache
always @ (posedge clk)
begin
    tag2=inst_cache_read_address[15:13];                               // storing 3 bit tag of requested address
    index2=inst_cache_read_address[12:3];                              // storing 10 bit index of requested address
    block_offset2=inst_cache_read_address[2:0];                        // storing 3 bit block offset of requested address
		if(inst_cache_tag[index2]==tag2 && inst_cache_valid[index2]==1)    // read hit if tag matches and the block is valid
  		 begin
    		inst_cache_is_read_hit=1;                                     // set inst_cache_is_read_hit(read hit)
    		inst_cache_inst_out=inst_cache[index2][block_offset2];        // getting instruction from cache from given index(line no.) and block offset
  		 end
		else //read miss
  		 begin
  		  inst_cache_is_read_hit=0;                                     // clear inst_cache_is_read_hit(read miss)
        block_no2=inst_cache_read_address[15:3];                      // block no. of requested address
        inst_cache[index2]=main_memory[block_no2];                    // storing requested block to cache from main_memory
        inst_cache_valid[index2]=1'b1;                                // set valid bit of line
        inst_cache_inst_out=inst_cache[index2][block_offset2];        // getting instruction from cache from given index(line no.) and block offset
        inst_cache_tag[index2]=tag2;                                  // updating tag of line
  		 end
end
////////////////////////////////////////////////


endmodule
