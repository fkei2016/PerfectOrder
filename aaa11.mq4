//+------------------------------------------------------------------+
//|                                                        aaa11.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 LimeGreen
//#property indicator_color2 Red
//---- input parameters
//int shift=0;
int i = 0;
int num=0;
int num1=0;
string textVar;
//---- buffers
double ExtMapBuffer1[];
//double ExtMapBuffer2[];
input int magic;
input int sp;
input int tp;
input  double lot = 1.0;
int Count;
int RV; //Return Value
int Ticket;
int tortal;
bool Ismartin;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---


SetIndexStyle(0,DRAW_ARROW);
SetIndexArrow(0,159);
SetIndexBuffer(0, ExtMapBuffer1);
Count = 1;
Ismartin = false;
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
int limit;
limit=1500;
for(int i=limit; i>=0; i--)
{
	ObjectDelete(""+i);
}	
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  
  int i = 0;
  int num=0;
  int num1=0;
  
  
  

   int CurrentPosition = 0;
   // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
      {
         CurrentPosition++;
      }
   }
   
   if(CurrentPosition == 0)
   {
      if(OrdersTotal() && Ismartin == true)
      {
         RV = OrderSelect(Ticket,SELECT_BY_TICKET);
         // TakeProfit
         Print("OrderProfit = ",OrderProfit());
         if(OrderProfit() > 0)
         {
            //RV = OrderClose(Ticket,OrderLots(),Bid,5);
            Count = 1;
            Ismartin = false;
         }
            // StopLoss
         if(OrderProfit() < 0)
         {
            //RV = OrderClose(Ticket,OrderLots(),Bid,5);
            Count *= 2;
            Ismartin = false;
         }
      }
   }




   for(int i=30; i>=0; i--)
   {
   
    if(Close[i+1]<Close[i+5])
    { 
       num = num + 1;
    }
    else
    {
       num = 0;
    }
    
    
	 if (num > 0 && num < 10) 
	 {
		textVar = num;
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num,0), 10, "Arial", Red);
      
    }
	 if (num == 9) 
	 {
		  ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
        ObjectSetText(""+i, ""+DoubleToStr(num,0), 16, "Arial", Red);
        //Print("i = ",i);
        /*if(i == 0 && CurrentPosition == 0)
           OrderSend(Symbol(), OP_BUY, 1.0, Ask, 3, Ask-(sp*Point),Ask+(tp*Point), "Buy", magic, 0, Blue);*/
    }				
	 else if((Close[i+1]<Close[i+5])&& num>=10)
	 {
		  ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
        ObjectSetText(""+i, ""+DoubleToStr(num,0), 10, "Arial", Orange);	
	 }
	 
	 if(num == 13 && i == 0 && CurrentPosition ==0)
	 {
	    Ticket = OrderSend(Symbol(), OP_BUY, lot * Count, Ask, 3, Ask-(sp*Point),Ask+(tp*Point), "Buy", magic, 0, Blue);
	    Ismartin = true;
	 }

    if(Close[i+1]>Close[i+5]) num1 = num1 + 1; 
    else num1 = 0;

	 if (num1 > 0 && num1 < 10) 
	 {
		textVar = num1;
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num1,0), 10, "Arial", RoyalBlue);
	 }
	 if (num1 == 9) 
	 {
		  ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
        ObjectSetText(""+i, ""+DoubleToStr(num1,0), 16, "Arial", RoyalBlue);
        //Print("i = ",i);
        /*if(i == 0 && CurrentPosition == 0)
           OrderSend(Symbol() ,OP_SELL, 1.0, Bid, 3,Bid+(sp*Point),Bid-(tp*Point), "Sella", magic, 0, Blue);*/
    }				
    else if((Close[i+1]>Close[i+5])&& num1>=10)
	 {
		  ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
        ObjectSetText(""+i, ""+DoubleToStr(num1,0), 10, "Arial", LightSkyBlue);
    }
    
    if(num1 == 13 && i == 0 && CurrentPosition ==0)
    {
       Ticket = OrderSend(Symbol() ,OP_SELL, lot * Count, Bid, 3,Bid+(sp*Point),Bid-(tp*Point), "Sella", magic, 0, Blue);
       Ismartin = true;
    }
    
   }
   
  }
//+------------------------------------------------------------------+
