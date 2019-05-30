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
   modifyFlag = false;
   goldenflag = false;
   deadflag = false;
   perfectExtension = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
     Print("GetPips = ",Getpips());
     Print("backTestEnd");
   
  }
  int time;
  int perfectExtension;
  bool modifyFlag;
  bool goldenflag;
  bool deadflag;
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

   float nowadx = iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0);
   float oldadx = iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,1);
   //エントリーフラグ
   switch(CrossSMA(EMA1,EMA3))
   {
     case 1: goldenflag = true;
             deadflag = false;
             break;
     
     case 2: goldenflag = false;
             deadflag = true;
             break;
   }
   //エントリーフラグ
   switch(CrossSMA(EMA1,EMA2))
   {
     case 1: goldenflag = true;
             deadflag = false;
             break;
     
     case 2: goldenflag = false;
             deadflag = true;
             break;
   }

   int abs = MathAbs(time - Hour());
   /*if(abs > 1)
   {
     time = Hour();
     if(CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,0)==1)
     {
        perfectExtension++;
     }
     if(perfectExtension >= 24)
     {
       goldenflag = true;
       deadflag = true;
       perfectExtension = 0;
     }
   
   }*/

   //最大で１０個ポジションを取る
   if(CurrentPosition <= 0 /*&& abs >= 12*/)
   {
     modifyFlag = false;
     //買いポジションをとる
     if(CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,0)==1 &&
        //CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,5)==1 &&
        //CrossMACandle(PERIOD_H1,EMA1,EMA2,1)==1 &&
        nowadx > oldadx && nowadx > 35 &&
        goldenflag == true)
      {
        int tiket = OrderSend(Symbol(), OP_BUY, 1.0 * MoneyManager(), Ask, 3, Ask-(250*Point),Ask+(750*Point), "Buy", 0, 0, Blue);
        goldenflag = false;
        deadflag = false;
        
      }
    //売りポジションをとる
    if(CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,0)==2 &&
       //CheckParfectOrder(PERIOD_H1,EMA1,EMA2,EMA3,5)==2 &&
       //CrossMACandle(PERIOD_H1,EMA1,EMA2,1)==2 &&
       nowadx > oldadx && nowadx > 35 &&
       deadflag == true)
      {
        int tiket = OrderSend(Symbol() ,OP_SELL, 1.0 * MoneyManager(), Bid, 3,Bid+(250*Point),Bid-(750*Point), "Sella", 0, 0, Blue);
        deadflag = false;
        goldenflag = false;
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
        if(OrderType()==OP_BUY && CrossMACandle(PERIOD_H1,EMA3,EMA3,1)==2)
        {
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
        }
        //売りポジションだった場合
        if(OrderType()==OP_SELL && CrossMACandle(PERIOD_H1,EMA3,EMA3,1)==1)
        {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
        }
        //買い時損切ライン格上げ（勝利確定ポジションに変更）
        if(OrderType()==OP_BUY && OrderOpenPrice() < Ask-(250*Point) && modifyFlag == false)
        {
          OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(150*Point),OrderTakeProfit(),0,Blue);
          modifyFlag = true;
        }
        //買い時損切ライン格上げ 2（勝利確定ポジションに変更）
        if(OrderType()==OP_BUY && OrderStopLoss() < Ask-(250*Point) && modifyFlag == true)
        {
          OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(200*Point),OrderTakeProfit(),0,Blue);
          modifyFlag = true;
        }
        //売り時損切ライン格上げ（勝利確定ポジションに変更）
        if(OrderType()==OP_SELL && OrderOpenPrice() > Bid+(250*Point) && modifyFlag == false)
        {
          OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(150*Point),OrderTakeProfit(),0,Blue);
          modifyFlag = true;
        }
        //売り時損切ライン格上げ 2（勝利確定ポジションに変更）
        if(OrderType()==OP_SELL && OrderStopLoss() > Bid+(250*Point) && modifyFlag == true)
        {
          OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(200*Point),OrderTakeProfit(),0,Blue);
          modifyFlag = true;
        }
      }
   }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
//関数名 CheckParfectOrder
//
//内容 n時間足でパーフェクトオーダーが発生しているかをチェックする
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

  //短期日線
  if((Open[1] <= now_fast_ma &&
     now_fast_ma <= Close[1]))
     return 1;
  
  if((Open[1] >= now_fast_ma &&
     now_fast_ma >= Close[1]))
     return 2;

  //中期日線
  if((Open[1] <= now_midle_ma &&
     now_midle_ma <= Close[1]))
     return 1;
  
  if((Open[1] >= now_midle_ma &&
     now_midle_ma >= Close[1]))
     return 2;

  return false;
}



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

//+------------------------------------------------------------------+
//
//関数名 MoneyManager
//
//内容 複利システム（ポジションサイズの計算）
//
//引数 なし
//
//戻り値　lot数
//+------------------------------------------------------------------+
double MoneyManager()
{

  double alots,blots;
  int clots;
  
  //１万ドルが口座にある場合、1ロットが十万通貨なので、１万で割る
  blots = AccountFreeMargin() * 0.05 / 250 * 0.01;

  //小数点第一位までで四捨五入するために、一度１０倍にして、０．５を足して、int型に入れる
  //clots = 10 * blots  + 0.5;

  //最後に、double型に0.1をかける。
  //alots = clots * 0.1 ;
  
  Print(blots);
  
  return(blots);
}


//+------------------------------------------------------------------+
//
//関数名 MoneyManager
//
//内容 複利システム（ポジションサイズの計算）
//
//引数 なし
//
//戻り値　lot数
//+------------------------------------------------------------------+
int Getpips()
{

    float pips = 0.0f;
    Print(OrdersHistoryTotal());

    for(int i = 0; i < OrdersHistoryTotal(); i++)
    {
        OrderSelect(i,SELECT_BY_POS, MODE_HISTORY);

        if(OrderSymbol() == Symbol())
        {
           if(OrderType() == OP_BUY)
           {
             pips += OrderClosePrice() - OrderOpenPrice();
             Print("OrderBUY =",OrderClosePrice() - OrderOpenPrice());
           }
           if(OrderType() == OP_SELL)
           {
             pips += OrderOpenPrice() - OrderClosePrice();
           }
        }
    }
    int pip = pips * 100;
    return pip;
}