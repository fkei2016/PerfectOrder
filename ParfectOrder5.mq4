//+------------------------------------------------------------------+
//|                                                ParfectOrder5.mq4 |
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
  int time;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   int CurrentPosition = 0;
   int order_select[10]; //最大１０個までポジションをもつ

   int EMA1 = 21; //移動平均期間 21
   int EMA2 = 48; //移動平均期間 48
   int EMA3 = 90; //移動平均期間 90

   // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select[CurrentPosition] = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition++;
      }
   }

   //最大で１０個ポジションを取る
   if(CurrentPosition <= 8 && (MathAbs(time - Minute()) >= 30))
   {
     //買いポジションをとる
     if(CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,0)==1 &&
        CheckParfectOrder(PERIOD_M30,EMA1,EMA2,EMA3,1)==1 &&
        CrossMACandle(PERIOD_M30,EMA1,EMA2,1)==1)
      {
        int tiket = OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(150*Point),0, "Buy", 0, 0, Blue);
        time = Minute();
      }
    //売りポジションをとる
    if(CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,0)==2 &&
       CheckParfectOrder(PERIOD_M30,EMA1,EMA2,EMA3,1)==2 &&
       CrossMACandle(PERIOD_M30,EMA1,EMA2,1)==2)
      {
        int tiket = OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(150*Point), 0, "Sella", 0, 0, Blue);
        time = Minute();
      }
   }

   //ポジション決済
   if(CurrentPosition >= 1)
   {
      for(int i =0; i < CurrentPosition; i++)
      {
        //ポジションの選択
        OrderSelect(i,SELECT_BY_POS);
        //買いポジションだった場合
        if(OrderType()==OP_BUY && CrossMACandle(PERIOD_M30,EMA1,EMA2,1)==2)
        {
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
        }
        //売りポジションだった場合
        if(OrderType()==OP_SELL && CrossMACandle(PERIOD_M30,EMA1,EMA2,1)==1)
        {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
        }
      }
   }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
//関数名 CheckParfectOrder
//
//内容 １時間足でパーフェクトオーダーが発生しているかをチェックする
//
//引数 int timeframe  何分足か
//     int EMA1       短期日線
//     int EMA2       中期日線
//     int EMA3       長期日線
//     int timeshift  何本前か
//
//戻り値　false:何も発生していない　1:買いのパーフェクトオーダー　2:売りのパーフェクトオーダー
//+------------------------------------------------------------------+
int CheckParfectOrder(int timeframe, int EMA1, int EMA2, int EMA3, int timeshift)
{
  double now_fast_ma;
  double now_midle_ma;
  double now_slow_ma;
   
  //短期日線
  now_fast_ma =  iMA(NULL,timeframe,EMA1,0,MODE_EMA,PRICE_CLOSE,timeshift);
  //中間日線
  now_midle_ma =  iMA(NULL,timeframe,EMA2,0,MODE_EMA,PRICE_CLOSE,timeshift);
  //長期日線
  now_slow_ma = iMA(NULL,timeframe,EMA3,0,MODE_EMA,PRICE_CLOSE,timeshift);

  if(now_fast_ma > now_midle_ma &&
     now_midle_ma> now_slow_ma)
     return 1;

  if(now_fast_ma < now_midle_ma&&
     now_midle_ma < now_slow_ma)
     return 2;  


  return false;
}


//+------------------------------------------------------------------+
//
//関数名 CrossMACandle
//
//内容 ろうそく足と短中期移動平均線が交わったかをチェックする
//
//引数 int timeframe  何分足か
//     int EMA1       短期日線
//     int EMA2       中期日線
//     int timeshift  何本前か
//
//戻り値　false:何も発生していない　1:買いの交わり　2:売りの交わり
//+------------------------------------------------------------------+
int CrossMACandle(int timeframe,int EMA1,int EMA2,int timeshift)
{

  double now_fast_ma;
  double now_midle_ma;

  //短期日線
  now_fast_ma =  iMA(NULL,timeframe,EMA1,0,MODE_EMA,PRICE_CLOSE,timeshift);
  //中間日線
  now_midle_ma =  iMA(NULL,timeframe,EMA2,0,MODE_EMA,PRICE_CLOSE,timeshift);


  if((Open[1] <= now_fast_ma &&
     now_fast_ma <= Close[1]))
     return 1;
  
  if((Open[1] >= now_fast_ma &&
     now_fast_ma >= Close[1]))
     return 2;


  return false;
}