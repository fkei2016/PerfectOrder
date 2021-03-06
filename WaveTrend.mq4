//+------------------------------------------------------------------+
//|                                                    WaveTrend.mq4 |
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
   
   // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   int irsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double adx = iADX(NULL,0,25,PRICE_CLOSE,MODE_MAIN,0);
   double pdi = iADX(NULL,0,25,PRICE_CLOSE,MODE_PLUSDI,0);
   double mdi = iADX(NULL,0,25,PRICE_CLOSE,MODE_MINUSDI,0);
   double stocha = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   
   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {
      if(irsi <= 30 && stocha <= 20)
      {
         OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(100*Point),0, "Buy", 0, 0, Blue);
      }
      if(irsi >= 70 && stocha >= 80)
      {
         OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(100*Point), 0, "Sella", 0, 0, Blue);
      }
   }
   //ポジションあり
   else
   {
     
     //ポジションの選択
     OrderSelect(CurrentPosition,SELECT_BY_POS);
     //買いポジションだった場合
     if(OrderType()==OP_BUY)
     {
        //パーフェクトオーダー終了
        if(irsi >= 50 || stocha >= 50)
        {
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
        }
     }
     //売りポジションだった場合
     if(OrderType()==OP_SELL)
     {
        //パーフェクトオーダー終了
       if(irsi <= 50 || stocha <= 50)
       {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
       }
     }
    }
   
   
   
  }
//+------------------------------------------------------------------+
