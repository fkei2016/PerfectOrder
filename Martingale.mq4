//+------------------------------------------------------------------+
//|                                                   Martingale.mq4 |
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
   lose =1;
   old_orderhistory_num = 0;
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
  int lose;
  int time;
  int old_orderhistory_num;
  input  double lot = 1.0;
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
   int orderhistory_num;
   bool Select_bool;
   int check_select_no;
   
   
   orderhistory_num = OrdersHistoryTotal();  // アカウント履歴の数を取得
   
   for(int i = orderhistory_num; i > 0; i--)
   {
     Select_bool = OrderSelect(i , SELECT_BY_POS , MODE_HISTORY); // アカウント履歴の任意の注文を選択

     if ( Select_bool == true ) 
     {
         
         if(OrderProfit() < 0)
         {
           lose *= 2;
         }
         else
         {
           i -= orderhistory_num;
         }
     } 
   }
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }

   int EMA1 = 21;  //移動平均期間 9
   int EMA2 = 48; //移動平均期間 36
   int EMA3 = 90; //移動平均期間 52

   double now_fast_ma;
   double now_slow_ma;
   
    //現在の短期日線
   now_fast_ma =  iMA(NULL,0,EMA1,0,MODE_EMA,PRICE_CLOSE,0);
   //現在の長期日線
   now_slow_ma = iMA(NULL,0,EMA2,0,MODE_EMA,PRICE_CLOSE,0);


   if(CurrentPosition == -1)
   {
     
      if(now_fast_ma > now_slow_ma && CrossSMA(EMA1,EMA3) == 1)
      {
        if(!OrderSend(Symbol(), OP_BUY, lot * lose, Ask, 3, Ask-(80*Point),Ask+(80*Point), "Buy", 0, 0, Blue))
        {
          Print(lose);
        }
      }
      //デッドクロス
      if(now_fast_ma < now_slow_ma && CrossSMA(EMA1,EMA3) == 2/* && BreakOut(24) == 2*/)
      {  
        if(!OrderSend(Symbol() ,OP_SELL, lot * lose, Bid, 3,Bid+(80*Point), Bid-(80*Point), "Sella", 0, 0, Blue))
        {
           Print(lose);
        }
      } 
   }
   lose = 1;
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
