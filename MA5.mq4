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

int check_select_no; // チェックする注文履歴番号
int time; //時間をチェックする
void OnTick()
{

//---
   //変数の宣言
   int cnt;
   int Position = -1;
   
   int order_send;
   int oeder_sell;
   int order_select;
   
   int orderhistory_num;
   bool Select_bool;
   int  err_code;
   
   int MA1 = 9;
   int MA2 = 36;
   int MA3 = 52;
   
   
   double now_fast_ma,now_slow_ma;
   
   
   //現在の短期日線
   now_fast_ma = iMA(NULL,0,MA1,0,MODE_SMA,PRICE_CLOSE,0);
   //現在の中間日線
   now_slow_ma =iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,0);
   
   int irsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
        Position =cnt;
      }
   }   
   // ポジションチェック　ポジション無し
   if(Position == -1 && Hour() != time)
   {
      //ゴールデンクロス
      if(now_fast_ma > now_slow_ma && CrossMA(MA1,MA3) == 1)
      {
         time =Hour();
         OrderSend(Symbol(), OP_BUY, 3, Ask, 40, Ask-(500*Point), 0, "Buyb", 0, 0, Red);
      }
      //デッドクロス
      if(now_fast_ma < now_slow_ma && CrossMA(MA1,MA3) == 2)
      {
         time =Hour();
         OrderSend(Symbol(), OP_SELL, 3, Bid, 40, Bid+(500*Point), 0, "Sella", 0, 0, Blue);
      }
   }
   // ポジション有り
   else 
   { 
     //ポジションの選択
     OrderSelect(Position,SELECT_BY_POS);
     //ポジションの確認
     if(OrderSymbol() == Symbol())
     {
       //もし買いポジションだったら
       if(OrderType() == OP_BUY) 
       {
          if(78 <= irsi)
          {
             OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
          }
       }
       //もし売りポジションだったら
       if(OrderType() == OP_SELL)
       {
           if(22 >= irsi)
           {
              OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
           }
       }
     }
   }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
//関数名 CrossMA
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
   old_fast_ma = iMA(NULL,0,fast,0,MODE_SMA,PRICE_CLOSE,1);
   //一時間前の長期日線
   old_slow_ma =iMA(NULL,0,slow,0,MODE_SMA,PRICE_CLOSE,1);
   
   //現在の短期日線
   now_fast_ma = iMA(NULL,0,fast,0,MODE_SMA,PRICE_CLOSE,0);
   //現在の長期日線
   now_slow_ma =iMA(NULL,0,slow,0,MODE_SMA,PRICE_CLOSE,0);
   
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