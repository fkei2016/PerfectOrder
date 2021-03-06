//+------------------------------------------------------------------+
//|                                                         iRSI.mq4 |
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
//--- //変数の宣言
   int cnt;
   int CurrentPosition = -1;
   
   int order_select;
   
   int positioncheck = 0;
   
   
   int SMA1 = 9;  //移動平均期間 9
   int SMA2 = 36; //移動平均期間 36
   int SMA3 = 52; //移動平均期間 52
   
   
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
  // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {
     //ゴールデンクロス
     if(SMA1 > SMA2 && CrossSMA(SMA1,SMA3) == 1)
     {
       OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(1000*Point),0, "Buy", 0, 0, Blue);

     }
     //デッドクロス
     if(SMA1 < SMA2 && CrossSMA(SMA1,SMA3) == 2)
     {
       OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(1000*Point), 0, "Sella", 0, 0, Blue);

     } 
   }
   //ポジションあり
   else
   {
     //ポジションの選択
     OrderSelect(CurrentPosition,SELECT_BY_POS);
     {
       //ゴールデンクロス
       if(SMA1 > SMA2 && CrossSMA(SMA1,SMA3) == 1)
       {
         OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);

       }
     //デッドクロス
       if(SMA1 < SMA2 && CrossSMA(SMA1,SMA3) == 2)
       {
         OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
       }
     }
    }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
//関数名 CrossSMA
//
//内容 ゴールデンクロスとデッドクロスを判断する関数
//
//引数 int fast  短期MA
//     int slow  長期MA
//
//戻り値　0:何も発生していない　1:ゴールデンクロス 2:デッドクロス
//+------------------------------------------------------------------+
int CrossSMA(int fast, int slow)
{


   double old_fast_ma;
   double old_slow_ma;
   double now_fast_ma;
   double now_slow_ma;
   
   //一時間前の短期日線
   old_fast_ma = iSMA(NULL,0,fast,PRICE_CLOSE,1);
   //一時間前の長期日線
   old_slow_ma =iSMA(NULL,0,slow,PRICE_CLOSE,1);
   
   //現在の短期日線
   now_fast_ma = iSMA(NULL,0,fast,PRICE_CLOSE,0);
   //現在の長期日線
   now_slow_ma =iSMA(NULL,0,slow,PRICE_CLOSE,0);
   
   //ゴールデンクロス
   if(old_fast_ma<old_slow_ma&&now_fast_ma>=now_slow_ma)
   {
      return(1);
   }
   
   //デッドクロス
   if(old_fast_ma>old_slow_ma&&now_fast_ma<=now_slow_ma)
   {
      return(2);
   }
   
   return(0);


}
