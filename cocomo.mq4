//+------------------------------------------------------------------+
//|                                                       cocomo.mq4 |
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
   int cnt;
   int CurrentPosition = -1;
   
   int order_select;
   
   int EMA1 = 21;  //移動平均期間 9
   int EMA2 = 48; //移動平均期間 36
   int EMA3 = 90; //移動平均期間 52
   
   
  
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
     if(CrossSMA(21,48) == 1)
     {
       OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(80*Point),Ask+(240*Point), "Buy", 0, 0, Blue);

     }
     //デッドクロス
     if(CrossSMA(21,48) == 2)
     {
       OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(80*Point),Bid-(240*Point), "Sella", 0, 0, Blue);
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
   old_fast_ma = iMA(NULL,0,fast,0,MODE_EMA,PRICE_CLOSE,1);
   //一時間前の長期日線
   old_slow_ma =iMA(NULL,0,slow,0,MODE_EMA,PRICE_CLOSE,1);
   
   //現在の短期日線
   now_fast_ma = iMA(NULL,0,fast,0,MODE_EMA,PRICE_CLOSE,0);
   //現在の長期日線
   now_slow_ma =iMA(NULL,0,slow,0,MODE_EMA,PRICE_CLOSE,0);
   
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