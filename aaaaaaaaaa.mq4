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
   time = 12;
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
   //変数の宣言
   int cnt;
   int CurrentPosition = 0;
   
   
   double old_fast_ma,old_slow_ma;
   double now_fast_ma,now_slow_ma;
   
   int order_send;
   int oeder_sell;
   int order_select;
   
   int orderhistory_num;
   bool Select_bool;
   int  err_code;
     
   
   
 // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select= OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition++;
      }
   }
   float nowadx = iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0);
   float oldadx = iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,1);
   
   //一時間前の２１日線
   old_fast_ma = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,1);
   //一時間前の９０日線
   old_slow_ma = iMA(NULL,0,52,0,MODE_EMA,PRICE_CLOSE,1);

   //現在の２１日線
   now_fast_ma = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,0);
   //現在の９０日線
   now_slow_ma = iMA(NULL,0,52,0,MODE_EMA,PRICE_CLOSE,0);
   
   
  
   int abs = MathAbs(time - Hour());
   //最大で１０個ポジションを取る
   if(CurrentPosition <= 0 && abs >= 6)
   {
     Print(abs);
     modifyFlag = false;
     //買いポジションをとる
     if(CheckParfectOrder(PERIOD_H1,36,36,0)==1 &&
        //CheckParfectOrder(PERIOD_H1,36,36,5)==1 &&
        //CrossMACandle(PERIOD_H1,36,36,1)==1 &&
        nowadx > oldadx && nowadx > 35)
      {
        int tiket = OrderSend(Symbol(), OP_BUY, 1.0 * MoneyManager(), Ask, 3, 0,0, "Buy", 0, 0, Blue);
     
        time = Hour();
        
      }
    //売りポジションをとる
    if(CheckParfectOrder(PERIOD_H1,36,36,0)==2 &&
       //CheckParfectOrder(PERIOD_H1,36,36,5)==2 &&
       //CrossMACandle(PERIOD_H1,36,36,1)==2 &&
       nowadx > oldadx && nowadx > 35)
      {
        int tiket = OrderSend(Symbol() ,OP_SELL, 1.0 * MoneyManager(), Bid, 3,0,0, "Sella", 0, 0, Blue);
       
         time = Hour();
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
        if(OrderType()==OP_BUY && CrossMACandle(PERIOD_H1,36,36,1)==2)
        {
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
        }
        //売りポジションだった場合
        if(OrderType()==OP_SELL && CrossMACandle(PERIOD_H1,36,36,1)==1)
        {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
        }
  
      }
   }
      
   
  
}
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
  if((Open[0] <= now_fast_ma &&
     now_fast_ma <= Close[0]))
     return 1;
  
  if((Open[0] >= now_fast_ma &&
     now_fast_ma >= Close[0]))
     return 2;

  //中期日線
  if((Open[0] <= now_midle_ma &&
     now_midle_ma <= Close[0]))
     return 1;
  
  if((Open[0] >= now_midle_ma &&
     now_midle_ma >= Close[0]))
     return 2;

  return false;
}


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
int CheckParfectOrder(int timeframe, int EMA1, int EMA2, int timeshift)
{
  double now_fast_ma;
  double now_midle_ma;
  double now_slow_ma;
  
   //短期日線
  now_fast_ma =  iMA(NULL,timeframe,EMA1,0,MODE_EMA,PRICE_CLOSE,timeshift);
  //中間日線
  now_midle_ma =  iMA(NULL,timeframe,EMA2,0,MODE_EMA,PRICE_CLOSE,timeshift);


  if(now_fast_ma > now_midle_ma)

     return 1;

  if(now_fast_ma < now_midle_ma)

     return 2;  


  return false;
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