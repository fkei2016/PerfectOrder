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
input double lot = 1.0;
input bool IsMartin;
int Count;
int lose;
int RV; //Return Value
int Ticket;
int tortal;
bool Ismartin;
int entrytime;
int updatetime;
bool modifyFlag;
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
lose = 0;
Ismartin = false;
entrytime = 0;
updatetime = 0;
modifyFlag = false;
   
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
  
  int array[9] = {1,1,2,3,5,8,13,21,34,55}; 
  
  

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
      if(Ismartin == true)
      {
         RV = OrderSelect(Ticket,SELECT_BY_TICKET);
         // StopLoss
         if(OrderProfit() < -100 * Count)
         {
            Count ++;
            lose ++;
            Ismartin = false;
            /*if(lose == 3)
            {
               lose = 0;
               Count ++;
            }*/
         }
         // TakeProfit
         else if(OrderProfit() > 100 * Count)
         {
            Count --;
            Ismartin = false;
            if(Count == 0)
            {
               Count = 1;
            }
         }
         Ismartin = false;
      }
      modifyFlag = false;
   }
   else
   {
      updatetime = TimeCurrent();
     //買い時損切ライン格上げ
     if(OrderType()==OP_BUY && OrderOpenPrice() < Ask-((tp-50)*Point) && modifyFlag == false)
     {
        OrderModify(OrderTicket(),OrderOpenPrice(),Ask-((tp-100)*Point),OrderTakeProfit(),0,Blue);
        modifyFlag = true;
     }
     //売り時損切ライン格上げ
     if(OrderType()==OP_SELL && OrderOpenPrice() > Bid+((tp-50)*Point) && modifyFlag == false)
     {
        OrderModify(OrderTicket(),OrderOpenPrice(),Bid+((tp-100)*Point),OrderTakeProfit(),0,Blue);
        modifyFlag = true;
     }
     if(TimeCurrent() > entrytime + 43200)
     {
        if(OrderType()==OP_BUY && OrderOpenPrice() < Ask-(100*Point) && modifyFlag == false)
        {
           if(OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(90*Point),OrderTakeProfit(),0,Blue))
           {
              entrytime = TimeCurrent();
           }
        }
        //売り時損切ライン格上げ
        if(OrderType()==OP_SELL && OrderOpenPrice() > Bid+(100*Point) && modifyFlag == false)
        {
           if(OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(90*Point),OrderTakeProfit(),0,Blue))
           {
              entrytime = TimeCurrent();
           }
        }
     }
   }
   if(!IsMartin)
      Count = 1;

   if(TimeCurrent() > updatetime + 900)
   {
   
   for(int i=50; i>=0; i--)
   {
   
    if(Close[i+1]<Close[i+5])
    { 
       num = num + 1;
    }
    else
    {
       num = 0;
    }
    
    double adx = iADX(NULL,0,14,PRICE_CLOSE,MODE_MAIN,1);
    double mdi = iADX(NULL,0,14,PRICE_CLOSE,MODE_MINUSDI	,1);
    double pdi = iADX(NULL,0,14,PRICE_CLOSE,MODE_PLUSDI,1);
	 if (num > 0 && num < 10) 
	 {
		textVar = num;
    }
	 if (num == 9) 
	 {
	    RV = OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);
       if(CurrentPosition != 0 && OrderType()==OP_SELL)
       {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
       }
    }				 
	 if(num == 13 && i == 0 && CurrentPosition ==0 && ((adx >= 34 && mdi >= 30) || (adx <= 33 && adx >= 25)))
	 {
	    Ticket = OrderSend(Symbol(), OP_BUY, lot * Count, Ask, 3, Ask-(sp*Point),Ask+(tp*Point), "Buy", magic, 0, Blue);
	    Ismartin = true;
	    entrytime = TimeCurrent();
	    updatetime = TimeCurrent();
	 }

    if(Close[i+1]>Close[i+5]) num1 = num1 + 1; 
    else num1 = 0;

	 if (num1 > 0 && num1 < 10) 
	 {
		textVar = num1;
	 }
	 if (num1 == 9) 
	 {
		 RV = OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES);
       if(CurrentPosition != 0 && OrderType()==OP_BUY)
       {
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
       }
        
    }				
    
    if(num1 == 13 && i == 0 && CurrentPosition ==0 && ((adx >= 34 && pdi >= 30) || (adx <= 33 && adx >= 25)))
    {
       Ticket = OrderSend(Symbol() ,OP_SELL, lot * Count, Bid, 3,Bid+(sp*Point),Bid-(tp*Point), "Sella", magic, 0, Blue);
       Ismartin = true;
       entrytime = TimeCurrent();
       updatetime = TimeCurrent();
    }
    
   }
   }
   
  }
//+------------------------------------------------------------------+
