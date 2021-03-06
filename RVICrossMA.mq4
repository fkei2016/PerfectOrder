//+------------------------------------------------------------------+
//|                                                   RVICrossMA.mq4 |
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
    time = 999;
    cross = false;
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
  int time;
  bool cross;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int order_select;
   int CurrentPosition = -1;
   
   double rvi100 = iRVI(NULL,0,100,MODE_MAIN,0);
   double ma9 = iMA(NULL,0,9,0,MODE_EMA,PRICE_CLOSE,0);
   double ma100 = iMA(NULL,0,100,0,MODE_EMA,PRICE_CLOSE,0);
   
   // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   //デットクロスかゴールデンクロス発生で取引を可能にする
   if(CrossMA(9,100) != 0)
   {
      cross = true;
   }
   
   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {
     //MA9がMA100より上抜けかつRVIの0ライン上抜け買い
     if(ma9 >= ma100 && rvi100 >= 0 && cross == true)
     {
       OrderSend(Symbol(), OP_BUY, 1, Ask, 3, 0, Ask+(100*Point), "Buy", 0, 0, Blue);
       cross = false;
     }
     //MA9がMA100より下抜けかつRVIの0ライン下抜け売り
     if(ma9 <= ma100 && rvi100 <= 0 && cross == true)
     {
       OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,0, Bid-(100*Point), "Sella", 0, 0, Blue);
       cross = false;
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
        double difference = (OrderOpenPrice()*100) - (Close[0]*100);
        if(difference <= 35)
        {
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
        }
     }
     //売りポジションだった場合
     if(OrderType()==OP_SELL)
     {
        int difference = (Close[0]*100) - (OrderOpenPrice()*100);
        if(difference >= 35)
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
int CrossMA(int fast, int slow)
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
