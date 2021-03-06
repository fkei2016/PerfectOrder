//+------------------------------------------------------------------+
//|                                                   Sample iMA.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
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
   //変数の宣言
   int cnt;
   int CurrentPosition = -1;
   
   int order_select;
   
   double old_fast_ma,old_slow_ma;
   double now_fast_ma,now_slow_ma;
   
   
   int irsi;
   
   int positioncheck = 0;
   
   
   //一時間前の２１日線
   old_fast_ma = iMA(NULL,0,21,0,MODE_SMA,PRICE_CLOSE,1);
   //一時間前の９０日線
   old_slow_ma = iMA(NULL,0,90,0,MODE_SMA,PRICE_CLOSE,1);

   //現在の２１日線
   now_fast_ma = iMA(NULL,0,21,0,MODE_SMA,PRICE_CLOSE,0);
   //現在の９０日線
   now_slow_ma = iMA(NULL,0,90,0,MODE_SMA,PRICE_CLOSE,0);
   
   
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   if((CurrentPosition == -1) && OrdersTotal() != 0)
   {
     //ポジションの選択
     OrderSelect(OrderTicket() ,SELECT_BY_POS);
     if(OrderType()==OP_BUY)
     {
       Print("sell");
       OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(1000*Point), 0, "Sella", 0, 0, Blue);
     }
     if(OrderType()==OP_SELL)
     {
       Print("BUY");
       OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(1000*Point),0, "Buy", 0, 0, Blue);
     }
   }
   
   irsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   
  // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {
     if(22 >= irsi)
     {
       OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(1000*Point),0, "Buy", 0, 0, Blue);

     }
     if(75 <= irsi)
     {
       OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(1000*Point), 0, "Sella", 0, 0, Blue);

     } 

   }
   
   if(CurrentPosition == 1)
   {
     if(22 >= irsi)
     {
         OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
     }
     if(75 <= irsi)
     {
         OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
     }
   }
   
  
   
}
//+------------------------------------------------------------------+
