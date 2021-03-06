//+------------------------------------------------------------------+
//|                                                       BBands.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int CurrentPosition = -1;
   
   int order_select;
   
   double ma21 = iMA(NULL,0,21,0,MODE_EMA,PRICE_CLOSE,0);
   double adx = iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0);
   
    // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   int abs = MathAbs(iBands(NULL,0,14,3,0,PRICE_CLOSE,MODE_LOWER,0)*10 - iBands(NULL,0,14,3,0,PRICE_CLOSE,MODE_UPPER,0)*10);
   
   
   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1 && abs >= 3)
   {
      if(iClose(NULL,0,0) <  iBands(NULL,0,14,3,0,PRICE_CLOSE,MODE_LOWER,0))
      {
         OrderSend(Symbol(),OP_BUY,1,Ask,3,Ask-(100*Point),Ask+(150*Point),"Buy",0,0,Blue);
      }
   }
  }
//+------------------------------------------------------------------+
