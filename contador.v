/* Hecho por Javier Nieto y Marcos Rivas
*/


//Modulo del biestable JK
module JKdown(output reg Q, output wire NQ, input wire J, input wire K,   input wire C);
  not(NQ,Q);

  initial
  begin
    Q=0;
  end    

  always @(posedge C)//Se activa por cada subida
    case ({J,K})
      2'b10: Q=1;
      2'b01: Q=0;
      2'b11: Q=~Q;
    endcase
endmodule


//Módulo que contiene el contador y la circuitería auxiliar.
module contador (output wire [3:0] Q, input wire C);
  //Cables correspondientes a las salidas negadas de los biestables.
  wire [3:0] nQ;
  //Cables que almacenan la salida temporal del biestable jk0.
  wire Qt, nQt;

  //Cables de entrada a los biestables.
  wire wJ3, wJ2, wJ1, wJ0, wK3, wK2, wK1, wK0;

  //Cables intermedios.
  wire wn0n2, wq0n2, wq1n0, wn3n1, wq3q1, wq2q0, wq3n2;

  //Puertas correspondientes al contador.
  and n0n2 (wn0n2, nQt, nQ[2]);
  or J3 (wJ3, wn0n2, Qt);

  and q0n2(wq0n2, Qt, nQ[2]);
  and q1n0(wq1n0, Q[1], nQt);
  or J1(wJ1, wq0n2, wq1n0);
  
  and J0 (wJ0, nQ[1], Q[2]);

  and n3n1 (wn3n1, nQ[3], nQ[1]);
  and q3q1 (wq3q1, Q[3], Q[1]);
  or K2 (wK2, wn3n1, wq3q1);

  JKdown jk0 (Qt, nQt, wJ0, nQ[2], C);
  JKdown jk1 (Q[1], nQ[1], wJ1, 1'b1, C);
  JKdown jk2 (Q[2], nQ[2], 1'b1, wK2, C);
  JKdown jk3 (Q[3], nQ[3], wJ3, 1'b1, C);

  //Circuitería adicional que cambia el uno por el 0.
  and  q2Q0 (wq2q0, Q[2], Qt);
  and  q3n2 (wq3n2, Q[3], nQ[2]);
  or   NQ0 (Q[0], wq2q0, wq3n2);
endmodule


//Módulo para probar el circuíto.
module test;
  reg I, C;
  wire [3:0] Q;
  contador counter (Q,C);

  always 
  begin
    #10 C=~C;
  end

  initial
  begin
    $dumpfile("contador.dmp");
    $dumpvars(2, counter, Q);
    
    counter.jk0.Q<=1;
    counter.jk1.Q<=0;
    counter.jk2.Q<=0;
    counter.jk3.Q<=1;
    $monitor($time, "C(%b) Q:%b (%d)", C,Q,Q);
    C=0;
    #250 $finish;
  end
endmodule

