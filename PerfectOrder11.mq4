//+------------------------------------------------------------------+
//|                                               PerfectOrder10.mq4 |
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
   time = 0;
   SPflag = false;
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
  input int magic;
  input int sp;
  input int tp;
  int time;
  double savepoint;
  bool SPflag;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   int CurrentPosition = 0;
   // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
      {
         CurrentPosition++;
      }
   }
   //移動平均線
   //上から
   //15分の１０本移動平均線
   //１時間足の10本移動平均線
   //15分の75本移動平均線
   //4時間の10本移動平均線
   double maM15 = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,0);
   double maH1 = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,0);
   double maM15_75 = iMA(NULL,PERIOD_M15,75,0,MODE_SMA,PRICE_CLOSE,0);
   double maH4 = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,0);

   double maM15_old2 = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,1);
   double maH4_old2 = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,1);
   
   double maM15_old = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,2);
   double maH1_old = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,2);
   double maM15_75_old = iMA(NULL,PERIOD_M15,75,0,MODE_SMA,PRICE_CLOSE,2);
   double maH4_old = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,2);

   //Bears Power
   double bear_now = iBearsPower(NULL,0,13,PRICE_CLOSE,0);
   double bear_old = iBearsPower(NULL,0,13,PRICE_CLOSE,2);
   
   //Bulls Power
   double bull_now = iBullsPower(NULL,0,13,PRICE_CLOSE,0);
   double bull_old = iBullsPower(NULL,0,13,PRICE_CLOSE,2);


   //コメント表示用
   Comment("ウホッ" ,"\n",
          "maM15         = ", maM15 ,"\n",
          "maH1           = ", maH1,"\n",
          "maM15_75    = ", maM15_75,"\n",
          "maH4           = ", maH4,"\n",
          "maM15_old2  = ", maM15_old2,"\n",
          "Close[1]        = ", Close[1],"\n"
          );

   //エントリー処理
   if(CurrentPosition == 0 && MathAbs(Minute() - time) >= 15)
   {
      //買いポジション
      if(bear_now > bear_old &&
         bull_now > bull_old &&
         CheckParfectOrder(PERIOD_M5,5,14,20,0) == 1 &&
         maH1 > maH1_old &&
         maM15_75 > maM15_75_old &&
         contactMA(maH4,maH4,maH4,maH4))
        {
          OrderSend(Symbol(), OP_BUY, 1.0, Ask, 3, Ask-(sp*Point),Ask+(tp*Point), "Buy", magic, 0, Blue);
          time = Minute();
          savepoint = Open[0];
          SPflag = false;
        }
      //売りポジション
      if(
         //bear_now > 0 && bull_now > 0 &&
         bear_now < bear_old &&
         bull_now < bull_old &&
         CheckParfectOrder(PERIOD_M5,5,14,20,0) == 2 &&
         maH1 < maH1_old &&
         maM15_75 < maM15_75_old &&
         contactMA(maH4,maH4,maH4,maH4))
         {
          OrderSend(Symbol() ,OP_SELL, 1.0, Bid, 3,Bid+(sp*Point),Bid-(tp*Point), "Sella", magic, 0, Blue);
          time = Minute();
          savepoint = Open[0];
          SPflag = false;
         }
    }
   //決済処理
   else if(CurrentPosition != 0)
   {
     if(Open[1] == savepoint)
        SPflag = true;
     //決済処理
     if(maH4_old2 < Close[1] &&
        SPflag == true)
     {
       //OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
     }
   }
   //例外処理
   else
   {

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
  now_fast_ma =  iMA(NULL,timeframe,EMA1,0,MODE_SMA,PRICE_CLOSE,timeshift);
  //中間日線
  now_midle_ma =  iMA(NULL,timeframe,EMA2,0,MODE_SMA,PRICE_CLOSE,timeshift);
  //長期日線
  now_slow_ma = iMA(NULL,timeframe,EMA3,0,MODE_SMA,PRICE_CLOSE,timeshift);

  if(now_fast_ma > now_midle_ma &&
     now_midle_ma> now_slow_ma)
     return 1;

  if(now_fast_ma < now_midle_ma&&
     now_midle_ma < now_slow_ma)
     return 2;  


  return false;
}



bool contactMA(double ma1,double ma2,double ma3,double ma4)
{
    if(Low[0] < ma1 &&
       High[0] > ma1)
       return true;
    if(Low[0] < ma2 &&
       High[0] > ma2)
       return true;
    if(Low[0] < ma3 &&
       High[0] > ma3)
       return true;
    if(Low[0] < ma4 &&
       High[0] > ma4)
       return true;
    

  return false;
}
